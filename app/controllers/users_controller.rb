class UsersController < ApplicationController
  before_action :require_admin!, only: :update

  def index
    @users = User.alphabetical
    @load = Issue.work.unfinished.where.not(assignee_id: nil).group(:assignee_id).sum("COALESCE(estimate, 1)")
    @open = Issue.work.unfinished.where.not(assignee_id: nil).group(:assignee_id).count
  end

  def show
    @user = User.find(params[:id])
    @issues = @user.assigned_issues.work.unfinished.includes(:project).order(Arel.sql("due_date IS NULL, due_date"))
    @done = @user.assigned_issues.work.done.where("completed_at >= ?", 30.days.ago).count
    @projects = @user.projects.alphabetical
  end

  def update
    user = User.find(params[:id])
    if user == current_user
      redirect_to users_path, alert: "Você não pode mudar o seu próprio papel."
    elsif user.update(role: params.require(:user).permit(:role)[:role])
      redirect_to users_path, notice: "Papel de #{user.name} atualizado."
    else
      redirect_to users_path, alert: user.errors.full_messages.to_sentence
    end
  end
end
