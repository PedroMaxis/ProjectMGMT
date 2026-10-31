ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Fábricas simples: cada teste monta só o que precisa, sem fixtures escondidas.
module Fabrica
  def criar_usuario(role: "member", **attrs)
    @n_usuarios = (@n_usuarios || 0) + 1
    User.create!({ name: "Pessoa #{@n_usuarios}", email: "pessoa#{@n_usuarios}-#{SecureRandom.hex(3)}@teste.dev", password: "senha1234", role: role }.merge(attrs))
  end

  def criar_projeto(key: "TST", lider: nil, **attrs)
    p = Project.create!({ name: "Projeto #{key}", key: key, start_date: Date.current - 10, due_date: Date.current + 50, priority: "medium", status: "active", lead: lider }.merge(attrs))
    p.memberships.create!(user: lider, role: "lead") if lider
    p
  end

  def criar_tarefa(projeto, **attrs)
    projeto.issues.create!({ title: "Tarefa #{SecureRandom.hex(2)}", kind: "task", priority: "medium" }.merge(attrs))
  end

  def criar_sprint(projeto, **attrs)
    projeto.sprints.create!({ name: "Sprint #{projeto.sprints.count + 1}", start_date: Date.current - 3, end_date: Date.current + 10 }.merge(attrs))
  end

  def entrar_como(usuario)
    post login_path, params: { email: usuario.email, password: "senha1234" }
  end
end

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    include Fabrica
    teardown { Current.reset }
  end
end

class ActionDispatch::IntegrationTest
  include Fabrica
end
