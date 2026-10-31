class Release < ApplicationRecord
  STATUSES = %w[planned in_progress released].freeze

  belongs_to :product
  has_many :issues, dependent: :nullify

  validates :name, presence: true, length: { maximum: 60 }
  validates :status, inclusion: { in: STATUSES }
  validates :released_on, presence: true, if: -> { status == "released" }

  def released? = status == "released"

  def progress
    total = issues.work.count
    return 0 if total.zero?
    (issues.work.done.count * 100.0 / total).round
  end

  def date = released_on || target_date
end
