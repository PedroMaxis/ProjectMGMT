class Membership < ApplicationRecord
  ROLES = %w[lead member viewer].freeze

  belongs_to :project
  belongs_to :user

  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :project_id }
end
