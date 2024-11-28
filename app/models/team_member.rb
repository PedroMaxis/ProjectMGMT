class TeamMember < ApplicationRecord
  belongs_to :project

  validates :name, :role, presence: true
end
