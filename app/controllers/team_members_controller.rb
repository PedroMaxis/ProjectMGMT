class TeamMembersController < ApplicationController
  before_action :set_team_member, only: %i[edit update destroy]

  def new
    @team_member = TeamMember.new(project_id: params[:project_id])
  end

  def create
    @team_member = TeamMember.new(team_member_params)
    if @team_member.save
      redirect_to project_path(@team_member.project), notice: 'Team member was successfully added.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @team_member.update(team_member_params)
      redirect_to project_path(@team_member.project), notice: 'Team member was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    project = @team_member.project
    @team_member.destroy
    redirect_to project_path(project), notice: 'Team member was successfully removed.'
  end

  private

  def set_team_member
    @team_member = TeamMember.find(params[:id])
  end

  def team_member_params
    params.require(:team_member).permit(:name, :role, :project_id)
  end
end
