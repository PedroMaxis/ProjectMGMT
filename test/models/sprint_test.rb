require "test_helper"

class SprintTest < ActiveSupport::TestCase
  setup { @projeto = criar_projeto }

  test "só pode haver uma sprint ativa por projeto" do
    criar_sprint(@projeto, status: "active")
    assert_raises(ActiveRecord::RecordInvalid) { criar_sprint(@projeto, status: "active") }
    assert criar_sprint(@projeto, status: "planned").persisted?
    assert criar_sprint(criar_projeto(key: "OUT"), status: "active").persisted?, "outro projeto pode ter a sua"
  end

  test "o fim não pode ser antes do início" do
    s = @projeto.sprints.new(name: "x", start_date: Date.current, end_date: Date.current - 1)
    assert_not s.valid?
  end

  test "pontos: total, concluídos e restantes ignoram épicos" do
    s = criar_sprint(@projeto)
    criar_tarefa(@projeto, sprint: s, estimate: 5, status: "done")
    criar_tarefa(@projeto, sprint: s, estimate: 3)
    criar_tarefa(@projeto, sprint: s) # 1 ponto
    assert_equal [ 9, 5, 4 ], [ s.total_points, s.done_points, s.remaining_points ]
  end

  test "start! ativa a sprint e já guarda a primeira foto do burndown" do
    s = criar_sprint(@projeto)
    criar_tarefa(@projeto, sprint: s, estimate: 8)
    s.start!
    assert s.active?
    assert_equal [ 8, 8 ], s.snapshots.pick(:remaining_points, :total_points)
  end

  test "capture_snapshot! regrava a foto do dia, sem duplicar" do
    s = criar_sprint(@projeto, status: "active")
    t = criar_tarefa(@projeto, sprint: s, estimate: 5)
    s.capture_snapshot!
    s.capture_snapshot!
    assert_equal 1, s.snapshots.count
    t.update_columns(status: "done")
    s.capture_snapshot!
    assert_equal 0, s.snapshots.first.remaining_points
  end

  test "concluir uma tarefa da sprint ativa atualiza o burndown de hoje sozinho" do
    s = criar_sprint(@projeto, status: "active")
    t = criar_tarefa(@projeto, sprint: s, estimate: 5)
    criar_tarefa(@projeto, sprint: s, estimate: 3)
    s.capture_snapshot!
    t.update!(status: "done")
    assert_equal 3, s.snapshots.find_by(day: Date.current).remaining_points
  end

  test "complete! leva o que sobrou ao backlog e mantém o que foi feito" do
    s = criar_sprint(@projeto, status: "active")
    feita = criar_tarefa(@projeto, sprint: s, status: "done", estimate: 3)
    pendente = criar_tarefa(@projeto, sprint: s, estimate: 5)
    s.complete!
    assert s.reload.completed?
    assert_not_nil s.completed_at
    assert_equal s.id, feita.reload.sprint_id
    assert_nil pendente.reload.sprint_id
    assert_equal 3, s.done_points
  end

  test "complete! pode levar as pendências para a próxima sprint" do
    s = criar_sprint(@projeto, status: "active")
    proxima = criar_sprint(@projeto, status: "planned", start_date: Date.current + 11, end_date: Date.current + 24)
    pendente = criar_tarefa(@projeto, sprint: s)
    s.complete!(move_unfinished_to: proxima)
    assert_equal proxima.id, pendente.reload.sprint_id
  end

  test "burndown: linha ideal vai do total a zero e a real para em hoje" do
    s = criar_sprint(@projeto, start_date: Date.current - 4, end_date: Date.current + 5, status: "active")
    2.times { criar_tarefa(@projeto, sprint: s, estimate: 5) }
    (0..2).each { |i| s.snapshots.create!(day: Date.current - 4 + i, remaining_points: 10 - i * 2, total_points: 10) }
    b = s.burndown
    assert_equal 10, b[:total]
    assert_equal 10, b[:ideal].first.last
    assert_equal 0, b[:ideal].last.last
    assert_equal 10, b[:days].size
    assert_equal [ 10, 8, 6 ], b[:actual].first(3).map(&:last)
    assert_operator b[:actual].last.first, :<=, Date.current
  end

  test "excluir a sprint devolve as tarefas ao backlog" do
    s = criar_sprint(@projeto)
    t = criar_tarefa(@projeto, sprint: s)
    s.destroy
    assert_nil t.reload.sprint_id
  end
end
