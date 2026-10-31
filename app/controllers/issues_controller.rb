class IssuesController < ApplicationController
  before_action :require_editor!, except: :show
  before_action :set_issue, only: %i[show update destroy move]

  def show
    @comments = @issue.comments.includes(:user)
    @events = @issue.events.includes(:user).limit(30)
    @children = @issue.children.includes(:assignee).ordered
    @members = @issue.project.users.alphabetical
    @sprints = @issue.project.sprints.open
    @epics = @issue.project.issues.epics.order(:title)
    @releases = @issue.project.product&.releases || Release.none
  end

  def new
    @project = Project.find_by!(key: params[:project_key])
    @issue = @project.issues.new(kind: params[:kind].presence_in(Issue::KINDS) || "task", status: params[:status].presence_in(Issue::STATUSES) || "todo", sprint_id: params[:sprint_id])
    carregar_opcoes
  end

  def create
    @project = Project.find_by!(key: params[:project_key])
    @issue = @project.issues.new(issue_params)
    @issue.reporter = current_user
    if @issue.save
      redirect_to(params[:return_to].presence_in(%w[board backlog]) == "backlog" ? backlog_project_path(@project) : (params[:return_to] == "board" ? board_project_path(@project) : issue_path(@issue)), notice: "#{@issue.key} criada.")
    else
      carregar_opcoes
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @issue.update(issue_params)
      redirect_to after_update_path, notice: "#{@issue.key} atualizada."
    else
      redirect_to after_update_path, alert: @issue.errors.full_messages.to_sentence
    end
  end

  def destroy
    projeto = @issue.project
    @issue.destroy
    redirect_to board_project_path(projeto), notice: "#{@issue.key} excluída."
  end

  # Chamado pelo arrastar e soltar do quadro: muda a coluna e a posição, e responde em JSON.
  def move
    status = params.require(:status)
    return render(json: { error: "Status inválido." }, status: :unprocessable_entity) unless Issue::STATUSES.include?(status)
    @issue.place!(status: status, after_id: params[:after_id])
    render json: { key: @issue.key, status: @issue.status, position: @issue.position, done: @issue.done? }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_issue = @issue = Issue.find_by_key!(params[:key])

  # de onde veio a edição: o backlog (mover para sprint) volta para o backlog; o resto, para a tarefa
  def after_update_path
    params[:return_to] == "backlog" ? backlog_project_path(@issue.project) : issue_path(@issue)
  end

  def carregar_opcoes
    @members = @project.users.alphabetical
    @sprints = @project.sprints.open
    @epics = @project.issues.epics.order(:title)
    @releases = @project.product&.releases || Release.none
  end

  def issue_params
    params.require(:issue).permit(:title, :description, :kind, :status, :priority, :estimate, :assignee_id, :start_date, :due_date, :sprint_id, :parent_id, :release_id, :labels_text)
  end
end
