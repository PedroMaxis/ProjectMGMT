require "test_helper"

class IssueTest < ActiveSupport::TestCase
  setup do
    @user = criar_usuario
    @projeto = criar_projeto(lider: @user)
  end

  test "a numeração é sequencial por projeto e a chave junta prefixo e número" do
    outro = criar_projeto(key: "OUT")
    a, b = criar_tarefa(@projeto), criar_tarefa(@projeto)
    assert_equal [ 1, 2 ], [ a.number, b.number ]
    assert_equal "TST-2", b.key
    assert_equal "OUT-1", criar_tarefa(outro).key
  end

  test "find_by_key! aceita minúsculas e levanta erro para chave inexistente ou malformada" do
    t = criar_tarefa(@projeto)
    assert_equal t, Issue.find_by_key!("tst-1")
    assert_raises(ActiveRecord::RecordNotFound) { Issue.find_by_key!("TST-99") }
    assert_raises(ActiveRecord::RecordNotFound) { Issue.find_by_key!("lixo") }
  end

  test "validações de campos" do
    assert_not @projeto.issues.new(title: "").valid?
    assert_not @projeto.issues.new(title: "x" * 201).valid?
    assert_not @projeto.issues.new(title: "ok", estimate: 4).valid?, "4 não está na escala 1,2,3,5,8,13"
    assert_not @projeto.issues.new(title: "ok", kind: "sonho").valid?
    assert_not @projeto.issues.new(title: "ok", start_date: Date.current, due_date: Date.current - 1).valid?
  end

  test "só épico pode ser pai, e épico não pode ter pai" do
    epico = criar_tarefa(@projeto, kind: "epic")
    comum = criar_tarefa(@projeto)
    assert criar_tarefa(@projeto, parent: epico).persisted?
    assert_not @projeto.issues.new(title: "x", parent: comum).valid?
    assert_not @projeto.issues.new(title: "x", kind: "epic", parent: epico).valid?
  end

  test "sprint e versão precisam ser do mesmo projeto/produto" do
    outro = criar_projeto(key: "OUT")
    assert_not Issue.new(project: @projeto, title: "x", sprint: criar_sprint(outro)).valid?
    produto = Product.create!(name: "Prod")
    versao = produto.releases.create!(name: "v1")
    assert_not Issue.new(project: @projeto, title: "x", release: versao).valid?, "projeto sem produto não aceita versão"
    @projeto.update!(product: produto)
    assert Issue.new(project: @projeto, title: "x", release: versao).valid?
  end

  test "completed_at é preenchido ao concluir e limpo ao reabrir" do
    t = criar_tarefa(@projeto)
    assert_nil t.completed_at
    t.update!(status: "done")
    assert_not_nil t.completed_at
    t.update!(status: "doing")
    assert_nil t.reload.completed_at
  end

  test "etiquetas são normalizadas: minúsculas, sem repetição, no máximo 8" do
    t = criar_tarefa(@projeto, labels_text: " API, api, Mobile ,, a1,a2,a3,a4,a5,a6,a7")
    assert_equal %w[api mobile a1 a2 a3 a4 a5 a6], t.labels
    assert_equal [], criar_tarefa(@projeto).reload.labels, "lista vazia volta como lista, não nil"
  end

  test "o histórico registra criação e cada mudança, com o autor" do
    Current.user = @user
    t = criar_tarefa(@projeto, reporter: @user)
    t.update!(status: "doing", priority: "high", estimate: 5, assignee: @user)
    tipos = t.events.map(&:kind)
    assert_includes tipos, "created"
    assert_includes tipos, "status_changed"
    assert_includes tipos, "priority_changed"
    assert_includes tipos, "estimate_changed"
    assert_includes tipos, "assigned"
    status = t.events.find { |e| e.kind == "status_changed" }
    assert_equal({ "from" => "todo", "to" => "doing" }, status.details)
    assert_equal @user, status.user
  end

  test "mudar sem alterar nada não gera evento" do
    t = criar_tarefa(@projeto)
    assert_no_difference -> { Event.count } do
      t.update!(title: t.title)
    end
  end

  test "place! põe a tarefa na coluna e ordena pelas vizinhas" do
    a, b, c = 3.times.map { |i| criar_tarefa(@projeto, title: "T#{i}", status: "doing") }
    d = criar_tarefa(@projeto, title: "D")
    d.place!(status: "doing", after_id: a.id) # entre A e B
    assert_equal [ a, d, b, c ].map(&:id), @projeto.issues.work.where(status: "doing").ordered.pluck(:id)
    d.place!(status: "doing", after_id: nil)  # topo
    assert_equal d.id, @projeto.issues.work.where(status: "doing").ordered.first.id
    d.place!(status: "doing", after_id: c.id) # fim
    assert_equal d.id, @projeto.issues.work.where(status: "doing").ordered.last.id
  end

  test "place! muda o status e conclui" do
    t = criar_tarefa(@projeto)
    t.place!(status: "done")
    assert t.reload.done?
    assert_not_nil t.completed_at
  end

  test "backlog tem só tarefas abertas, fora de sprint e que não são épicos" do
    aberta = criar_tarefa(@projeto)
    criar_tarefa(@projeto, status: "done")
    criar_tarefa(@projeto, kind: "epic")
    criar_tarefa(@projeto, sprint: criar_sprint(@projeto))
    assert_equal [ aberta ], @projeto.issues.backlog.to_a
  end

  test "atrasada: prazo no passado e não concluída" do
    atrasada = criar_tarefa(@projeto, due_date: Date.current - 2)
    criar_tarefa(@projeto, due_date: Date.current - 2, status: "done")
    criar_tarefa(@projeto, due_date: Date.current + 2)
    assert_equal [ atrasada ], @projeto.issues.overdue.to_a
    assert atrasada.overdue?
  end

  test "busca por título ou descrição trata % e _ como texto" do
    criar_tarefa(@projeto, title: "Corrigir login", description: "senha")
    criar_tarefa(@projeto, title: "Meta 100% concluída")
    assert_equal 1, Issue.search("login").count
    assert_equal 1, Issue.search("senha").count
    assert_equal 1, Issue.search("100%").count
    assert_equal 1, Issue.search("%").count, "o % é texto: só a tarefa que tem % casa, não todas"
    assert_equal 0, Issue.search("_").count, "o _ também é texto, não 'qualquer letra'"
  end
end
