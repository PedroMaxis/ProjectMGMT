class Milestone < ApplicationRecord
  belongs_to :project

  validates :title, :due_date, presence: true

  def completed? = completed_on.present?
  def late?(today = Date.current) = !completed? && due_date < today
end
