class MilestonesController < ApplicationController
  before_action :set_milestone, only: %i[edit update destroy]

  def new
    @milestone = Milestone.new(project_id: params[:project_id])
  end

  def create
    @milestone = Milestone.new(milestone_params)
    if @milestone.save
      redirect_to project_path(@milestone.project), notice: 'Milestone was successfully added.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @milestone.update(milestone_params)
      redirect_to project_path(@milestone.project), notice: 'Milestone was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    project = @milestone.project
    @milestone.destroy
    redirect_to project_path(project), notice: 'Milestone was successfully removed.'
  end

  private

  def set_milestone
    @milestone = Milestone.find(params[:id])
  end

  def milestone_params
    params.require(:milestone).permit(:title, :description, :due_date, :completed, :project_id)
  end
end
