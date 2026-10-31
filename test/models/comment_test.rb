require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "exige texto e registra um evento no histórico da tarefa" do
    u = criar_usuario
    t = criar_tarefa(criar_projeto)
    assert_not t.comments.new(user: u, body: " ").valid?
    assert_difference -> { t.events.where(kind: "commented").count }, 1 do
      t.comments.create!(user: u, body: "Olá")
    end
  end
end
