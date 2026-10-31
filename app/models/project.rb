class Project < ApplicationRecord
  PRIORITIES = %w[low medium high].freeze
  STATUSES = %w[planning active on_hold completed].freeze

  belongs_to :lead, class_name: "User", optional: true
  belongs_to :product, optional: true
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :milestones, -> { order(:due_date) }, dependent: :destroy
  has_many :sprints, -> { order(:start_date, :id) }, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :events, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :pages, dependent: :destroy

  normalizes :key, with: ->(k) { k.to_s.strip.upcase }

  validates :name, presence: true, length: { maximum: 80 }
  validates :key, presence: true, uniqueness: true, format: { with: /\A[A-Z][A-Z0-9]{1,5}\z/, message: :invalid_key }
  validates :start_date, :due_date, presence: true
  validates :priority, inclusion: { in: PRIORITIES }
  validates :status, inclusion: { in: STATUSES }
  validate :due_date_after_start

  scope :alphabetical, -> { order(Arel.sql("name COLLATE NOCASE")) }
  scope :open, -> { where.not(status: "completed") }

  def to_param = key

  def active_sprint = sprints.find_by(status: "active")

  # pontos concluídos / pontos totais (tarefa sem estimativa vale 1 ponto, para o andamento não ficar zerado)
  def progress
    total = issues.work.sum("COALESCE(estimate, 1)")
    return (status == "completed" ? 100 : 0) if total.zero?
    (issues.work.done.sum("COALESCE(estimate, 1)") * 100.0 / total).round
  end

  # "on_track", "at_risk" ou "late": compara o andamento com o tempo que já passou do cronograma
  def health(today = Date.current)
    return "done" if status == "completed"
    return "paused" if status == "on_hold"
    return "late" if due_date < today
    span = (due_date - start_date).to_f
    return "on_track" if span <= 0 || today < start_date
    expected = ((today - start_date) / span * 100).clamp(0, 100)
    progress + 15 < expected ? "at_risk" : "on_track"
  end

  def days_left(today = Date.current) = (due_date - today).to_i

  private

  def due_date_after_start
    errors.add(:due_date, :before_start) if start_date && due_date && due_date < start_date
  end
end
