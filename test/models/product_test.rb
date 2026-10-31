require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "o slug sai do nome e nunca se repete" do
    a = Product.create!(name: "Lume Pró")
    b = Product.create!(name: "Lume Pró")
    assert_equal "lume-pro", a.slug
    assert_equal "lume-pro-2", b.slug
    assert_equal "lume-pro", a.to_param
  end

  test "versão lançada precisa da data de lançamento" do
    p = Product.create!(name: "P")
    assert_not p.releases.new(name: "v1", status: "released").valid?
    assert p.releases.new(name: "v1", status: "released", released_on: Date.current).valid?
  end

  test "andamento do produto soma os projetos dele" do
    p = Product.create!(name: "P")
    proj = criar_projeto(product: p)
    criar_tarefa(proj, estimate: 5, status: "done")
    criar_tarefa(proj, estimate: 5)
    assert_equal 50, p.progress
    assert_equal 0, Product.create!(name: "Vazio").progress
  end

  test "andamento da versão usa só as tarefas ligadas a ela" do
    p = Product.create!(name: "P")
    proj = criar_projeto(product: p)
    v = p.releases.create!(name: "v1")
    criar_tarefa(proj, release: v, status: "done")
    criar_tarefa(proj, release: v)
    criar_tarefa(proj)
    assert_equal 50, v.progress
  end
end
