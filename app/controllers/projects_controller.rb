class ProjectsController < ApplicationController
  before_action :require_editor!, only: %i[new create edit update destroy]
  before_action :set_project, except: %i[index new create]

  def index
    @status = params[:status].presence_in(Project::STATUSES)
    @projects = Project.includes(:lead, :product).alphabetical
    @projects = @projects.where(status: @status) if @status
    @counts = Project.group(:status).count
  end

  def show
    @sprint = @project.active_sprint
    @members = @project.memberships.includes(:user).order(:role)
    @milestones = @project.milestones
    @recent = @project.events.includes(:user, :issue).limit(8)
    @by_status = @project.issues.work.group(:status).count
    @candidates = User.alphabetical.where.not(id: @project.user_ids)
  end

  def new
    @project = Project.new(start_date: Date.current, due_date: 2.months.from_now.to_date, lead: current_user)
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      @project.memberships.create(user: @project.lead, role: "lead") if @project.lead
      redirect_to @project, notice: "Projeto criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Projeto atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Projeto excluído com todas as tarefas."
  end

  # Quadro Kanban: mostra a sprint ativa (ou tudo, se não houver sprint ativa, ou se pedirem "todas")
  def board
    @sprint = @project.active_sprint
    @show_all = @sprint.nil? || params[:scope] == "all"
    scope = @project.issues.work.includes(:assignee, :parent)
    scope = scope.where(sprint_id: @sprint.id) unless @show_all
    scope = filtrar(scope)
    @columns = Issue::STATUSES.index_with { |s| scope.where(status: s).ordered }
    @epics = @project.issues.epics.order(:title)
    @members = @project.users.alphabetical
    @filters_active = %i[assignee kind epic q label].any? { |k| params[k].present? }
  end

  def backlog
    @sprints = @project.sprints.open.includes(issues: %i[assignee parent])
    @backlog = filtrar(@project.issues.backlog.includes(:assignee, :parent)).ordered
    @epics = @project.issues.epics.order(:title)
    @members = @project.users.alphabetical
  end

  def timeline
    @epics = @project.issues.epics.includes(:children).order(:start_date, :id)
    @sprints = @project.sprints.where.not(start_date: nil)
    @milestones = @project.milestones
    @range = timeline_range
  end

  def reports
    @sprint = @project.sprints.find_by(id: params[:sprint]) || @project.active_sprint || @project.sprints.where(status: "completed").last
    @burndown = @sprint&.burndown
    @velocity = @project.sprints.where(status: "completed").to_a.last(6).map { |s| [ s.name.split("·").first.strip, s.done_points ] }
    @by_kind = @project.issues.work.group(:kind).count
    @by_status = @project.issues.work.group(:status).count
    @by_assignee = @project.issues.work.unfinished.group(:assignee_id).sum("COALESCE(estimate, 1)")
    @people = User.where(id: @by_assignee.keys.compact).index_by(&:id)
    @throughput = semanas_concluidas
  end

  private

  def set_project = @project = Project.find_by!(key: params[:key] || params[:id])

  def project_params
    params.require(:project).permit(:name, :key, :description, :start_date, :due_date, :priority, :status, :lead_id, :product_id, :color)
  end

  def filtrar(scope)
    scope = scope.where(assignee_id: params[:assignee] == "none" ? nil : params[:assignee]) if params[:assignee].present?
    scope = scope.where(kind: params[:kind]) if params[:kind].present?
    scope = scope.where(parent_id: params[:epic]) if params[:epic].present?
    scope = scope.search(params[:q]) if params[:q].present?
    scope = scope.matching("issues.labels", "\"#{params[:label].to_s.downcase}\"") if params[:label].present?
    scope
  end

  def timeline_range
    datas = [ @project.start_date, @project.due_date ] + @epics.flat_map { |e| [ e.start_date, e.due_date ] } + @sprints.flat_map { |s| [ s.start_date, s.end_date ] } + @milestones.map(&:due_date)
    datas = datas.compact
    inicio = datas.min.beginning_of_month
    fim = datas.max.end_of_month
    (inicio..fim)
  end

  # tarefas concluídas por semana nas últimas 8 semanas
  def semanas_concluidas
    hoje = Date.current.beginning_of_week
    (0..7).to_a.reverse.map do |i|
      ini = hoje - i.weeks
      [ ini, @project.issues.work.done.where(completed_at: ini.beginning_of_day...(ini + 7).beginning_of_day).count ]
    end
  end
end
