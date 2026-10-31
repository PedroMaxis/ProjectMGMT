require "test_helper"

class PageTest < ActiveSupport::TestCase
  setup do
    @projeto = criar_projeto
    @produto = Product.create!(name: "Prod")
  end

  test "pertence a um projeto OU a um produto, nunca aos dois nem a nenhum" do
    assert Page.new(title: "a", project: @projeto).valid?
    assert Page.new(title: "a", product: @produto).valid?
    assert_not Page.new(title: "a").valid?
    assert_not Page.new(title: "a", project: @projeto, product: @produto).valid?
  end

  test "a página-mãe precisa estar no mesmo espaço" do
    pai = @produto.pages.create!(title: "pai")
    assert_not @projeto.pages.new(title: "filha", parent: pai).valid?
    assert @produto.pages.new(title: "filha", parent: pai).valid?
  end

  test "não aceita ciclos na hierarquia" do
    a = @projeto.pages.create!(title: "A")
    b = @projeto.pages.create!(title: "B", parent: a)
    c = @projeto.pages.create!(title: "C", parent: b)
    assert_not a.update(parent: c), "A dentro de C (que está dentro de A) criaria um ciclo"
    assert_not a.update(parent: a)
    assert_equal [ a, b ], Page.find(c.id).ancestors # recarregado: a tentativa inválida acima mexeu no objeto em memória
  end

  test "excluir uma página exclui as subpáginas" do
    a = @projeto.pages.create!(title: "A")
    @projeto.pages.create!(title: "B", parent: a)
    assert_difference -> { Page.count }, -2 do
      a.destroy
    end
  end
end
