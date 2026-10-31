class ApplicationController < ActionController::Base
  before_action :require_login
  before_action :set_current_user

  helper_method :current_user, :can_edit?

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def can_edit? = current_user&.can_edit?

  def require_login
    redirect_to login_path, alert: "Entre para continuar." unless current_user
  end

  def set_current_user
    Current.user = current_user
  end

  # Leitores só visualizam: qualquer escrita é barrada aqui, no servidor (esconder o botão não basta).
  def require_editor!
    return if can_edit?
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: "Seu perfil é de leitura: você não pode alterar dados." }
      format.json { render json: { error: "Perfil de leitura." }, status: :forbidden }
      format.any { head :forbidden }
    end
  end

  def require_admin!
    return if current_user&.admin?
    redirect_to root_path, alert: "Somente administradores podem fazer isso."
  end

  def not_found
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found, layout: "application" }
      format.json { render json: { error: "Não encontrado." }, status: :not_found }
      format.any { head :not_found }
    end
  end
end
