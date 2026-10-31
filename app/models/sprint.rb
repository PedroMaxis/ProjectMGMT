class Sprint < ApplicationRecord
  STATUSES = %w[planned active completed].freeze

  belongs_to :project
  has_many :issues, dependent: :nullify
  has_many :snapshots, class_name: "SprintSnapshot", dependent: :destroy

  validates :name, presence: true, length: { maximum: 60 }
  validates :status, inclusion: { in: STATUSES }
  validates :start_date, :end_date, presence: true
  validate :end_after_start
  validate :single_active_sprint, if: -> { status == "active" }

  scope :open, -> { where.not(status: "completed") }

  def planned? = status == "planned"
  def active? = status == "active"
  def completed? = status == "completed"

  # peso de cada tarefa: a estimativa em pontos (ou 1, se ainda não foi estimada)
  def work_issues = issues.work
  def total_points = work_issues.sum("COALESCE(estimate, 1)")
  def done_points = work_issues.done.sum("COALESCE(estimate, 1)")
  def remaining_points = total_points - done_points

  def start!
    update!(status: "active", start_date: [ start_date, Date.current ].compact.min)
    capture_snapshot!
  end

  # Encerra a sprint. O que não ficou pronto volta ao backlog ou vai para outra sprint.
  def complete!(move_unfinished_to: nil)
    transaction do
      capture_snapshot!
      work_issues.where.not(status: "done").update_all(sprint_id: move_unfinished_to&.id, updated_at: Time.current)
      update!(status: "completed", completed_at: Time.current)
    end
  end

  # Guarda como estava o trabalho restante hoje (uma linha por dia, regravada a cada alteração).
  def capture_snapshot!(day = Date.current)
    snap = snapshots.find_or_initialize_by(day: day)
    snap.update!(remaining_points: remaining_points, total_points: total_points)
  end

  # Dados do burndown: dias úteis da sprint, linha ideal e linha real (até hoje)
  def burndown(today = Date.current)
    return nil unless start_date && end_date
    dias = (start_date..end_date).to_a
    total = snapshots.order(:day).first&.total_points || total_points
    ideal = dias.each_with_index.map { |d, i| [ d, (total * (1 - i.to_f / [ dias.size - 1, 1 ].max)).round(1) ] }
    por_dia = snapshots.index_by(&:day)
    ultimo = total
    real = dias.filter_map do |d|
      next if d > today && !completed?
      ultimo = por_dia[d].remaining_points if por_dia[d]
      [ d, ultimo ]
    end
    { days: dias, ideal: ideal, actual: real, total: total }
  end

  private

  def end_after_start
    errors.add(:end_date, :before_start) if start_date && end_date && end_date < start_date
  end

  def single_active_sprint
    outra = project.sprints.where(status: "active").where.not(id: id).exists?
    errors.add(:base, :another_active) if outra
  end
end
