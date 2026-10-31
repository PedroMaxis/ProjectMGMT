class Issue < ApplicationRecord
  KINDS = %w[task bug story epic].freeze
  STATUSES = %w[todo doing review done].freeze
  PRIORITIES = %w[low medium high urgent].freeze
  ESTIMATES = [ 1, 2, 3, 5, 8, 13 ].freeze
  KEY_FORMAT = /\A([A-Z][A-Z0-9]{1,5})-(\d+)\z/
  GAP = 1024.0 # espaço entre posições vizinhas: permite inserir no meio sem renumerar a coluna

  belongs_to :project
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :reporter, class_name: "User", optional: true
  belongs_to :sprint, optional: true
  belongs_to :parent, class_name: "Issue", optional: true, inverse_of: :children
  belongs_to :release, optional: true
  has_many :children, class_name: "Issue", foreign_key: :parent_id, inverse_of: :parent, dependent: :nullify
  has_many :comments, -> { order(:created_at, :id) }, dependent: :destroy
  has_many :events, -> { order(created_at: :desc, id: :desc) }, dependent: :destroy

  serialize :labels, coder: JSON, type: Array

  before_validation :assign_number, on: :create
  before_validation :assign_position, on: :create
  before_validation :normalize_labels
  before_save :track_completion
  after_create_commit :record_creation
  after_update_commit :record_changes
  after_commit :refresh_sprint_snapshots

  validates :title, presence: true, length: { maximum: 200 }
  validates :kind, inclusion: { in: KINDS }
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }
  validates :estimate, inclusion: { in: ESTIMATES }, allow_nil: true
  validates :number, uniqueness: { scope: :project_id }
  validate :due_date_after_start
  validate :parent_must_be_epic
  validate :sprint_and_release_belong_to_project

  scope :epics, -> { where(kind: "epic") }
  scope :work, -> { where.not(kind: "epic") } # tudo que não é épico: o que de fato se executa
  scope :done, -> { where(status: "done") }
  scope :unfinished, -> { where.not(status: "done") }
  scope :backlog, -> { work.unfinished.where(sprint_id: nil) }
  scope :overdue, -> { unfinished.where("due_date < ?", Date.current) }
  scope :ordered, -> { order(:position, :id) }
  scope :search, ->(termo) { matching(%w[issues.title issues.description], termo) }

  def self.find_by_key!(key)
    chave, numero = key.to_s.upcase.match(KEY_FORMAT)&.captures
    raise ActiveRecord::RecordNotFound, "Tarefa #{key} não encontrada" unless chave
    joins(:project).find_by!(projects: { key: chave }, number: numero.to_i)
  end

  # campo de formulário: etiquetas separadas por vírgula
  def labels_text = labels.join(", ")
  def labels_text=(texto)
    self.labels = texto.to_s.split(",")
  end

  def key = "#{project.key}-#{number}"
  def to_param = key
  def epic? = kind == "epic"
  def done? = status == "done"
  def overdue?(today = Date.current) = due_date.present? && due_date < today && !done?
  def weight = estimate || 1

  # Coloca a tarefa em uma coluna do quadro logo abaixo de `after_id` (ou no topo, se for nil).
  def place!(status:, after_id: nil)
    coluna = project.issues.work.where(status: status).where.not(id: id).ordered
    referencia = after_id.present? ? coluna.find_by(id: after_id) : nil
    nova =
      if referencia
        proxima = coluna.where("position > ?", referencia.position).first
        proxima ? (referencia.position + proxima.position) / 2.0 : referencia.position + GAP
      else
        primeira = coluna.first
        primeira ? primeira.position - GAP : GAP
      end
    update!(status: status, position: nova)
  end

  private

  def assign_number
    return if number.present? || project.nil?
    self.number = Issue.where(project_id: project_id).maximum(:number).to_i + 1
  end

  def assign_position
    return if position.to_f.positive? || project.nil?
    self.position = Issue.where(project_id: project_id, status: status).maximum(:position).to_f + GAP
  end

  def normalize_labels
    self.labels = Array(labels).map { |l| l.to_s.strip.downcase }.reject(&:blank?).uniq.first(8)
  end

  def track_completion
    self.completed_at = done? ? (completed_at || Time.current) : nil if status_changed? || new_record?
  end

  def due_date_after_start
    errors.add(:due_date, :before_start) if start_date && due_date && due_date < start_date
  end

  def parent_must_be_epic
    return unless parent
    errors.add(:parent_id, :not_epic) unless parent.epic?
    errors.add(:parent_id, :epic_cannot_have_parent) if epic?
    errors.add(:parent_id, :other_project) if parent.project_id != project_id
  end

  def sprint_and_release_belong_to_project
    errors.add(:sprint_id, :other_project) if sprint && sprint.project_id != project_id
    errors.add(:release_id, :other_product) if release && release.product_id != project&.product_id
  end

  def record_creation
    Event.record!(issue: self, kind: "created", user: reporter || Current.user, details: { title: title, kind: kind })
  end

  def record_changes
    mudancas = saved_changes
    registrar = ->(kind, details) { Event.record!(issue: self, kind: kind, details: details) }
    registrar.call("status_changed", { from: mudancas["status"][0], to: mudancas["status"][1] }) if mudancas.key?("status")
    registrar.call("priority_changed", { from: mudancas["priority"][0], to: mudancas["priority"][1] }) if mudancas.key?("priority")
    registrar.call("title_changed", { from: mudancas["title"][0], to: mudancas["title"][1] }) if mudancas.key?("title")
    registrar.call("estimate_changed", { from: mudancas["estimate"][0], to: mudancas["estimate"][1] }) if mudancas.key?("estimate")
    if mudancas.key?("assignee_id")
      registrar.call("assigned", { from: User.find_by(id: mudancas["assignee_id"][0])&.name, to: assignee&.name })
    end
    if mudancas.key?("sprint_id")
      registrar.call("sprint_changed", { from: Sprint.find_by(id: mudancas["sprint_id"][0])&.name, to: sprint&.name })
    end
  end

  # o burndown da sprint ativa acompanha qualquer mudança de status, estimativa ou sprint
  def refresh_sprint_snapshots
    ids = [ sprint_id, sprint_id_before_last_save ].compact.uniq
    Sprint.where(id: ids, status: "active").find_each(&:capture_snapshot!) if ids.any?
  end
end
