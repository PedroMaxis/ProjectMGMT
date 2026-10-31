require "test_helper"

class FluxosTest < ActionDispatch::IntegrationTest
  setup do
    @user = criar_usuario
    @projeto = criar_projeto(lider: @user)
    entrar_como(@user)
  end

  test "criar projeto: a chave vira prefixo e o líder entra na equipe" do
    post projects_path, params: { project: { name: "Novo", key: "nov", start_date: Date.current, due_date: Date.current + 30, priority: "high", status: "planning", lead_id: @user.id } }
    projeto = Project.find_by!(key: "NOV")
    assert_redirected_to project_path(projeto)
    assert_equal "lead", projeto.memberships.find_by(user: @user).role
  end

  test "projeto inválido volta ao formulário com erros" do
    post projects_path, params: { project: { name: "", key: "1" } }
    assert_response :unprocessable_entity
    assert_match "não pode ficar em branco", response.body
  end

  test "criar tarefa pelo projeto: o autor vira relator e o evento é registrado" do
    assert_difference -> { @projeto.issues.count }, 1 do
      post project_issues_path(@projeto), params: { issue: { title: "Corrigir cadastro", kind: "bug", priority: "high", estimate: 3, labels_text: "API, mobile" }, return_to: "board" }
    end
    t = @projeto.issues.last
    assert_redirected_to board_project_path(@projeto)
    assert_equal [ "TST-1", @user, %w[api mobile] ], [ t.key, t.reporter, t.labels ]
    assert_equal "created", t.events.last.kind
  end

  test "tarefa inválida não é criada" do
    assert_no_difference -> { Issue.count } do
      post project_issues_path(@projeto), params: { issue: { title: "", estimate: 4 } }
    end
    assert_response :unprocessable_entity
  end

  test "atualizar campos pela tarefa registra o histórico com o autor" do
    t = criar_tarefa(@projeto)
    patch issue_path(t), params: { issue: { status: "review", assignee_id: @user.id, estimate: 8 } }
    assert_redirected_to issue_path(t)
    t.reload
    assert_equal [ "review", @user.id, 8 ], [ t.status, t.assignee_id, t.estimate ]
    assert_equal [ @user ], t.events.where(kind: "status_changed").map(&:user)
  end

  test "mover no quadro (JSON): muda a coluna e responde com o novo estado" do
    a = criar_tarefa(@projeto, status: "doing")
    t = criar_tarefa(@projeto)
    patch move_issue_path(t), params: { status: "doing", after_id: a.id }, as: :json
    assert_response :success
    corpo = response.parsed_body
    assert_equal [ "TST-2", "doing", false ], [ corpo["key"], corpo["status"], corpo["done"] ]
    assert_operator t.reload.position, :>, a.position

    patch move_issue_path(t), params: { status: "done" }, as: :json
    assert response.parsed_body["done"]
    assert_not_nil t.reload.completed_at
  end

  test "mover para status inválido responde 422 e não altera nada" do
    t = criar_tarefa(@projeto)
    patch move_issue_path(t), params: { status: "voando" }, as: :json
    assert_response :unprocessable_entity
    assert_equal "todo", t.reload.status
  end

  test "ciclo da sprint pela interface: criar, iniciar, concluir levando pendências à próxima" do
    post project_sprints_path(@projeto), params: { sprint: { name: "S1", goal: "Meta", start_date: Date.current, end_date: Date.current + 10 } }
    s1 = @projeto.sprints.find_by!(name: "S1")
    feita = criar_tarefa(@projeto, sprint: s1, status: "done", estimate: 2)
    pendente = criar_tarefa(@projeto, sprint: s1, estimate: 3)

    post start_project_sprint_path(@projeto, s1)
    assert_redirected_to board_project_path(@projeto)
    assert s1.reload.active?

    post project_sprints_path(@projeto), params: { sprint: { name: "S2", start_date: Date.current + 11, end_date: Date.current + 20 } }
    s2 = @projeto.sprints.find_by!(name: "S2")
    post start_project_sprint_path(@projeto, s2)
    assert_redirected_to backlog_project_path(@projeto), "não inicia uma segunda sprint ativa"
    assert s2.reload.planned?

    post complete_project_sprint_path(@projeto, s1), params: { move_to: s2.id }
    assert s1.reload.completed?
    assert_equal s2.id, pendente.reload.sprint_id
    assert_equal s1.id, feita.reload.sprint_id
  end

  test "comentar: qualquer membro; excluir: só o autor ou admin" do
    t = criar_tarefa(@projeto)
    post issue_comments_path(t), params: { comment: { body: "Primeiro" } }
    c = t.comments.last
    assert_equal @user, c.user

    delete logout_path
    entrar_como(criar_usuario)
    delete issue_comment_path(t, c)
    assert Comment.exists?(c.id), "outro membro não exclui"

    delete logout_path
    entrar_como(criar_usuario(role: "admin"))
    delete issue_comment_path(t, c)
    assert_not Comment.exists?(c.id), "admin exclui"
  end

  test "marcos: criar, concluir (alternar) e excluir" do
    post project_milestones_path(@projeto), params: { milestone: { title: "Beta", due_date: Date.current + 5 } }
    m = @projeto.milestones.last
    patch project_milestone_path(@projeto, m), params: { toggle: 1 }
    assert m.reload.completed?
    patch project_milestone_path(@projeto, m), params: { toggle: 1 }
    assert_not m.reload.completed?
    delete project_milestone_path(@projeto, m)
    assert_equal 0, @projeto.milestones.count
  end

  test "equipe do projeto: adicionar e remover; o mesmo usuário não entra duas vezes" do
    novo = criar_usuario
    post project_memberships_path(@projeto), params: { membership: { user_id: novo.id, role: "member" } }
    assert_equal 2, @projeto.memberships.count
    post project_memberships_path(@projeto), params: { membership: { user_id: novo.id, role: "member" } }
    assert_equal 2, @projeto.memberships.count
    delete project_membership_path(@projeto, @projeto.memberships.find_by(user: novo))
    assert_equal 1, @projeto.memberships.count
  end

  test "produto com versões; marcar como lançada preenche a data" do
    post products_path, params: { product: { name: "Aurora", status: "active" } }
    produto = Product.find_by!(slug: "aurora")
    post product_releases_path(produto), params: { release: { name: "v1", status: "planned", target_date: Date.current + 9 } }
    v = produto.releases.last
    patch product_release_path(produto, v), params: { release: { status: "released" } }
    assert_equal [ "released", Date.current ], [ v.reload.status, v.released_on ]
  end
end
