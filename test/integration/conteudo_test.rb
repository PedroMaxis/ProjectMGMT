require "test_helper"

class ConteudoTest < ActionDispatch::IntegrationTest
  setup do
    @user = criar_usuario(name: "Maria Souza")
    @projeto = criar_projeto(lider: @user)
    entrar_como(@user)
  end

  test "o Markdown é renderizado e o HTML perigoso é removido" do
    post markdown_preview_path, params: { text: "# Título\n\n**negrito** <script>alert(1)</script> <img src=x onerror=alert(2)> [x](javascript:alert(3))" }
    assert_response :success
    assert_includes response.body, "<h1>Título</h1>"
    assert_includes response.body, "<strong>negrito</strong>"
    assert_no_match(/<script/i, response.body)
    assert_no_match(/onerror/i, response.body)
    assert_no_match(/href=["']?javascript/i, response.body) # vira texto puro, nunca um link executável
  end

  test "menções @nome viram destaque só para quem existe" do
    post markdown_preview_path, params: { text: "Oi @maria e @ninguem" }
    assert_includes response.body, '<span class="mention">@Maria</span>'
    assert_includes response.body, "@ninguem"
    assert_no_match(/mention">@ninguem/, response.body)
  end

  test "páginas: criar em projeto, aninhar e impedir ciclo" do
    post project_pages_path(@projeto), params: { page: { title: "Guia", body: "# Oi" } }
    pai = @projeto.pages.last
    assert_redirected_to page_path(pai)
    post project_pages_path(@projeto), params: { page: { title: "Filha", parent_id: pai.id } }
    filha = @projeto.pages.find_by!(title: "Filha")
    assert_equal pai, filha.parent

    patch page_path(pai), params: { page: { parent_id: filha.id } }
    assert_response :unprocessable_entity
    assert_nil pai.reload.parent_id

    get page_path(filha)
    assert_response :success
    assert_select ".tree a.active", text: /Filha/
  end

  test "a tela de página mostra o texto sem executar HTML embutido" do
    pagina = @projeto.pages.create!(title: "XSS", body: "<script>window.hack=1</script>\n\nTexto seguro")
    get page_path(pagina)
    assert_includes response.body, "Texto seguro"
    assert_no_match(/<script>window\.hack/, response.body)
  end

  test "busca: JSON agrupado por tipo, exige 2 letras e acha tarefa pela chave" do
    criar_tarefa(@projeto, title: "Ajustar fatura do cartão")
    criar_tarefa(@projeto, title: "Outra coisa")
    @projeto.pages.create!(title: "Guia de fatura")

    get search_path(q: "fatura", format: :json)
    corpo = response.parsed_body
    assert_equal [ "Ajustar fatura do cartão" ], corpo["issues"].map { |i| i["title"] }
    assert_equal [ "Guia de fatura" ], corpo["pages"].map { |i| i["title"] }

    get search_path(q: "f", format: :json)
    assert_equal({ "issues" => [], "projects" => [], "products" => [], "pages" => [], "users" => [] }, response.parsed_body)

    get search_path(q: "TST-2", format: :json)
    assert_equal [ "Outra coisa" ], response.parsed_body["issues"].map { |i| i["title"] }
  end

  test "busca na tela não quebra com caracteres especiais" do
    get search_path(q: "100% _ \\")
    assert_response :success
  end

  test "as telas principais renderizam para todos os papéis" do
    t = criar_tarefa(@projeto, title: "Algo", estimate: 3)
    s = criar_sprint(@projeto, status: "active")
    t.update!(sprint: s)
    s.capture_snapshot!
    [ root_path, projects_path, project_path(@projeto), board_project_path(@projeto), backlog_project_path(@projeto), timeline_project_path(@projeto),
      reports_project_path(@projeto), issue_path(t), products_path, roadmap_path, users_path, user_path(@user) ].each do |rota|
      get rota
      assert_response :success, "#{rota} falhou"
    end
  end

  test "a tarefa aberta dentro de um Turbo Frame vem só com o painel (sem o layout)" do
    t = criar_tarefa(@projeto)
    get issue_path(t), headers: { "Turbo-Frame" => "issue_panel" }
    assert_response :success
    assert_select "turbo-frame#issue_panel .drawer"
    assert_select ".app", count: 0
  end

  test "o quadro mostra só a sprint ativa e 'todas' mostra tudo" do
    s = criar_sprint(@projeto, status: "active")
    criar_tarefa(@projeto, title: "Na sprint", sprint: s)
    criar_tarefa(@projeto, title: "Fora da sprint")
    get board_project_path(@projeto)
    assert_match "Na sprint", response.body
    assert_no_match(/Fora da sprint/, response.body)
    get board_project_path(@projeto, scope: "all")
    assert_match "Fora da sprint", response.body
  end

  test "filtros do quadro: responsável, tipo e texto" do
    criar_tarefa(@projeto, title: "Bug da tela", kind: "bug", assignee: @user)
    criar_tarefa(@projeto, title: "Tarefa solta")
    get board_project_path(@projeto, kind: "bug")
    assert_match "Bug da tela", response.body
    assert_no_match(/Tarefa solta/, response.body)
    get board_project_path(@projeto, assignee: "none")
    assert_match "Tarefa solta", response.body
    get board_project_path(@projeto, q: "solta")
    assert_no_match(/Bug da tela/, response.body)
  end
end
