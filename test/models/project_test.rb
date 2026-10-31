require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "a chave é normalizada em maiúsculas, única e com formato válido" do
    p = criar_projeto(key: " web ")
    assert_equal "WEB", p.key
    assert_not Project.new(name: "Outro", key: "WEB", start_date: Date.current, due_date: Date.current + 1).valid?
    %w[1AB A A_B ABCDEFG].each do |k|
      assert_not Project.new(name: "X", key: k, start_date: Date.current, due_date: Date.current + 1).valid?, "#{k} deveria ser inválida"
    end
  end

  test "o prazo não pode ser antes do início" do
    p = Project.new(name: "X", key: "XX", start_date: Date.current, due_date: Date.current - 1, priority: "low", status: "active")
    assert_not p.valid?
    assert_includes p.errors.attribute_names, :due_date
  end

  test "andamento é pontos concluídos sobre pontos totais; tarefa sem estimativa vale 1; épico não conta" do
    p = criar_projeto
    criar_tarefa(p, estimate: 3, status: "done")
    criar_tarefa(p, estimate: 5)
    criar_tarefa(p, status: "done") # sem estimativa: 1 ponto
    criar_tarefa(p, kind: "epic")
    assert_equal 4 * 100 / 9, p.progress # 4 de 9 pontos
  end

  test "projeto sem tarefas tem andamento zero (ou 100 se já concluído)" do
    assert_equal 0, criar_projeto(key: "AAA").progress
    assert_equal 100, criar_projeto(key: "BBB", status: "completed").progress
  end

  test "saúde: no prazo, em risco, atrasado, concluído e pausado" do
    hoje = Date.new(2026, 6, 15)
    base = { start_date: Date.new(2026, 6, 1), due_date: Date.new(2026, 6, 30) }
    assert_equal "late", criar_projeto(key: "LT", **base).health(Date.new(2026, 7, 5))
    assert_equal "done", criar_projeto(key: "DN", status: "completed", **base).health(hoje)
    assert_equal "paused", criar_projeto(key: "PS", status: "on_hold", **base).health(hoje)

    em_risco = criar_projeto(key: "RK", **base) # metade do prazo, nada feito
    criar_tarefa(em_risco, estimate: 5)
    assert_equal "at_risk", em_risco.health(hoje)

    no_prazo = criar_projeto(key: "OK", **base)
    criar_tarefa(no_prazo, estimate: 5, status: "done")
    criar_tarefa(no_prazo, estimate: 5)
    assert_equal "on_track", no_prazo.health(hoje)
  end

  test "to_param usa a chave" do
    assert_equal "TST", criar_projeto.to_param
  end

  test "excluir o projeto apaga tarefas, sprints, marcos e páginas" do
    p = criar_projeto
    t = criar_tarefa(p)
    criar_sprint(p)
    p.milestones.create!(title: "M", due_date: Date.current)
    p.pages.create!(title: "Doc")
    p.destroy
    assert_not Issue.exists?(t.id)
    assert_equal 0, Sprint.count + Milestone.count + Page.count
  end
end
