class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create demo]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to login_path, alert: "Muitas tentativas. Aguarde alguns minutos." }

  layout "auth"

  def new
    redirect_to root_path if current_user
    @demo_users = User.alphabetical if demo_enabled?
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user&.authenticate(params[:password].to_s)
      entrar(user)
    else
      @demo_users = User.alphabetical if demo_enabled?
      flash.now[:alert] = "E-mail ou senha incorretos."
      render :new, status: :unprocessable_entity
    end
  end

  # Entrada com um clique nos perfis de demonstração (para quem avalia o projeto não precisar de senha).
  def demo
    return head(:not_found) unless demo_enabled?
    entrar(User.find(params[:id]))
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Você saiu."
  end

  private

  def demo_enabled? = Rails.configuration.x.demo_login

  def entrar(user)
    reset_session # evita fixação de sessão
    session[:user_id] = user.id
    redirect_to root_path, notice: "Olá, #{user.first_name}!"
  end
end
