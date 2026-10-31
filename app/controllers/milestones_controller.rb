class MilestonesController < ApplicationController
  before_action :require_editor!
  before_action :set_project

  def create
    milestone = @project.milestones.new(milestone_params)
    if milestone.save
      redirect_to @project, notice: "Marco criado."
    else
      redirect_to @project, alert: milestone.errors.full_messages.to_sentence
    end
  end

  # alterna concluído/pendente
  def update
    milestone = @project.milestones.find(params[:id])
    attrs = params[:toggle].present? ? { completed_on: milestone.completed? ? nil : Date.current } : milestone_params
    if milestone.update(attrs)
      redirect_to @project, notice: "Marco atualizado."
    else
      redirect_to @project, alert: milestone.errors.full_messages.to_sentence
    end
  end

  def destroy
    @project.milestones.find(params[:id]).destroy
    redirect_to @project, notice: "Marco excluído."
  end

  private

  def set_project = @project = Project.find_by!(key: params[:project_key])
  def milestone_params = params.require(:milestone).permit(:title, :description, :due_date)
end
