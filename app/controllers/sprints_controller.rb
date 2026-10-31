class SprintsController < ApplicationController
  before_action :require_editor!
  before_action :set_project
  before_action :set_sprint, only: %i[update destroy start complete]

  def create
    sprint = @project.sprints.new(sprint_params)
    if sprint.save
      redirect_to backlog_project_path(@project), notice: "#{sprint.name} criada."
    else
      redirect_to backlog_project_path(@project), alert: sprint.errors.full_messages.to_sentence
    end
  end

  def update
    if @sprint.update(sprint_params)
      redirect_to backlog_project_path(@project), notice: "#{@sprint.name} atualizada."
    else
      redirect_to backlog_project_path(@project), alert: @sprint.errors.full_messages.to_sentence
    end
  end

  def destroy
    @sprint.destroy
    redirect_to backlog_project_path(@project), notice: "Sprint excluída. As tarefas voltaram ao backlog."
  end

  def start
    @sprint.start!
    redirect_to board_project_path(@project), notice: "#{@sprint.name} iniciada."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to backlog_project_path(@project), alert: e.record.errors.full_messages.to_sentence
  end

  def complete
    destino = @project.sprints.where(status: "planned").find_by(id: params[:move_to])
    pendentes = @sprint.work_issues.unfinished.count
    @sprint.complete!(move_unfinished_to: destino)
    aviso = "#{@sprint.name} concluída."
    aviso += pendentes.positive? ? " #{pendentes} #{pendentes == 1 ? 'tarefa pendente foi' : 'tarefas pendentes foram'} para #{destino ? destino.name : 'o backlog'}." : ""
    redirect_to reports_project_path(@project, sprint: @sprint.id), notice: aviso
  end

  private

  def set_project = @project = Project.find_by!(key: params[:project_key])
  def set_sprint = @sprint = @project.sprints.find(params[:id])
  def sprint_params = params.require(:sprint).permit(:name, :goal, :start_date, :end_date)
end
