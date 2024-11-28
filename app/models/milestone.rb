class Milestone < ApplicationRecord
  belongs_to :project

  validates :title, :due_date, presence: true
end
