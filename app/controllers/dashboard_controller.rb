class DashboardController < ApplicationController
  def show
    @projects = Project.open.includes(:lead, :product).alphabetical
    @my_issues = current_user.assigned_issues.work.unfinished.includes(:project).order(Arel.sql("due_date IS NULL, due_date"), :position).limit(8)
    @overdue = Issue.work.overdue.includes(:project, :assignee).order(:due_date).limit(5)
    @by_status = Issue.work.group(:status).count
    @events = Event.recent.includes(:user, issue: :project).limit(10)
    @workload = Issue.work.unfinished.where.not(assignee_id: nil).group(:assignee_id).sum("COALESCE(estimate, 1)")
    @people = User.where(id: @workload.keys).index_by(&:id)
    @sprints = Sprint.where(status: "active").includes(:project)
    @milestones = Milestone.where(completed_on: nil).where("due_date >= ?", Date.current).includes(:project).order(:due_date).limit(4)
    @health = @projects.group_by(&:health)
  end
end
