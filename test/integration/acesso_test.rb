require "test_helper"

class AcessoTest < ActionDispatch::IntegrationTest
  test "sem login, tudo redireciona para a tela de entrada" do
    [ root_path, projects_path, products_path, roadmap_path, users_path, search_path ].each do |rota|
      get rota
      assert_redirected_to login_path, "#{rota} deveria exigir login"
    end
  end

  test "login correto entra; senha errada não entra e não vaza se o e-mail existe" do
    u = criar_usuario
    post login_path, params: { email: u.email, password: "errada123" }
    assert_response :unprocessable_entity
    erro1 = response.body[/E-mail ou senha incorretos/]
    post login_path, params: { email: "ninguem@teste.dev", password: "errada123" }
    assert_equal erro1, response.body[/E-mail ou senha incorretos/], "mesma mensagem para e-mail inexistente"
    post login_path, params: { email: u.email.upcase, password: "senha1234" }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "sair encerra a sessão" do
    u = criar_usuario
    entrar_como(u)
    delete logout_path
    get root_path
    assert_redirected_to login_path
  end

  test "o login troca o identificador de sessão (contra fixação de sessão)" do
    u = criar_usuario
    get root_path # redireciona com aviso: cria a sessão anônima
    nome, antes = cookies.to_hash.find { |k, _| k.include?("session") }
    assert antes.present?, "deveria haver um cookie de sessão"
    entrar_como(u)
    assert_not_equal antes, cookies[nome], "o identificador da sessão precisa mudar ao entrar"
  end

  test "login de demonstração entra com um clique quando está ligado, e some quando está desligado" do
    u = criar_usuario
    post demo_login_path(u)
    assert_redirected_to root_path
    delete logout_path

    anterior = Rails.configuration.x.demo_login
    begin
      Rails.configuration.x.demo_login = false
      post demo_login_path(u)
      assert_response :not_found
      get login_path
      assert_no_match "prumo123", response.body
    ensure
      Rails.configuration.x.demo_login = anterior
    end
  end

  test "leitor só visualiza: escritas são barradas no servidor" do
    leitor = criar_usuario(role: "viewer")
    projeto = criar_projeto
    tarefa = criar_tarefa(projeto)
    entrar_como(leitor)

    get project_path(projeto)
    assert_response :success

    assert_no_difference -> { Issue.count } do
      post project_issues_path(projeto), params: { issue: { title: "Nova" } }
    end
    assert_redirected_to root_path

    patch move_issue_path(tarefa), params: { status: "done" }, as: :json
    assert_response :forbidden
    assert_equal "todo", tarefa.reload.status

    assert_no_difference -> { Project.count } do
      post projects_path, params: { project: { name: "X", key: "XX", start_date: Date.current, due_date: Date.current + 5, priority: "low", status: "active" } }
    end
    delete project_path(projeto)
    assert Project.exists?(projeto.id)
  end

  test "só administrador muda o papel dos outros, e ninguém muda o próprio" do
    admin = criar_usuario(role: "admin")
    membro = criar_usuario
    outro = criar_usuario

    entrar_como(membro)
    patch user_path(outro), params: { user: { role: "admin" } }
    assert_equal "member", outro.reload.role

    delete logout_path
    entrar_como(admin)
    patch user_path(outro), params: { user: { role: "viewer" } }
    assert_equal "viewer", outro.reload.role
    patch user_path(admin), params: { user: { role: "viewer" } }
    assert_equal "admin", admin.reload.role
    patch user_path(outro), params: { user: { role: "dono" } }
    assert_equal "viewer", outro.reload.role, "papel inválido é recusado"
  end

  test "página inexistente responde 404 limpo" do
    entrar_como(criar_usuario)
    get "/issues/ZZZ-99"
    assert_response :not_found
    get "/projects/NAOEXISTE"
    assert_response :not_found
  end
end
