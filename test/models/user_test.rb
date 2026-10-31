require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normaliza o e-mail e exige senha de 8 caracteres" do
    u = criar_usuario(email: "  Ana@Exemplo.COM ")
    assert_equal "ana@exemplo.com", u.email
    assert_not User.new(name: "X", email: "x@x.com", password: "curta").valid?
  end

  test "e-mail é único e precisa ser válido" do
    criar_usuario(email: "a@a.com")
    assert_not User.new(name: "B", email: "A@a.com", password: "senha1234").valid?
    assert_not User.new(name: "B", email: "invalido", password: "senha1234").valid?
  end

  test "iniciais, primeiro nome e menção sem acento" do
    u = criar_usuario(name: "Fernanda Reis")
    assert_equal "FR", u.initials
    assert_equal "Fernanda", u.first_name
    assert_equal "fernanda", u.mention_handle
    assert_equal "joao", criar_usuario(name: "João Lima").mention_handle
  end

  test "leitor não edita; membro e admin sim" do
    assert_not criar_usuario(role: "viewer").can_edit?
    assert criar_usuario(role: "member").can_edit?
    assert criar_usuario(role: "admin").can_edit?
  end

  test "papel inválido é recusado" do
    assert_not User.new(name: "X", email: "x@x.com", password: "senha1234", role: "root").valid?
  end
end
