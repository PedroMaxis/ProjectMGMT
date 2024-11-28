class Project < ApplicationRecord
    has_many :team_members, dependent: :destroy
    has_many :milestones, dependent: :destroy
  
    validates :name, :start_date, :due_date, :priority, :status, presence: true
    validates :priority, inclusion: { in: %w[High Medium Low] }
    validates :status, inclusion: { in: %w[Not\ Started In\ Progress Completed] }
  end
  