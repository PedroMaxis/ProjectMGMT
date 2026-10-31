class MembershipsController < ApplicationController
  before_action :require_editor!
  before_action :set_project

  def create
    # nada de mass assignment: a pessoa é procurada pelo id e o papel só vale se estiver na lista fechada
    papel = params.dig(:membership, :role).presence_in(Membership::ROLES) || "member"
    m = @project.memberships.new(user: User.find(params.dig(:membership, :user_id)), role: papel)
    if m.save
      redirect_to @project, notice: "#{m.user.name} entrou no projeto."
    else
      redirect_to @project, alert: m.errors.full_messages.to_sentence
    end
  end

  def destroy
    m = @project.memberships.find(params[:id])
    m.destroy
    redirect_to @project, notice: "#{m.user.name} saiu do projeto."
  end

  private

  def set_project = @project = Project.find_by!(key: params[:project_key])
end
