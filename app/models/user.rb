class User < ApplicationRecord
  ROLES = %w[admin member viewer].freeze
  COLORS = %w[#7c3aed #0d9488 #db2777 #ea580c #16a34a #9333ea #0891b2 #ca8a04].freeze

  has_secure_password

  has_many :memberships, dependent: :destroy
  has_many :projects, through: :memberships
  has_many :assigned_issues, class_name: "Issue", foreign_key: :assignee_id, inverse_of: :assignee, dependent: :nullify
  has_many :comments, dependent: :destroy

  normalizes :email, with: ->(e) { e.to_s.strip.downcase }

  validates :name, presence: true, length: { maximum: 80 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: ROLES }
  validates :password, length: { minimum: 8 }, allow_nil: true

  scope :alphabetical, -> { order(Arel.sql("name COLLATE NOCASE")) }

  def initials
    name.split.map { |p| p[0] }.first(2).join.upcase
  end

  def admin? = role == "admin"
  def viewer? = role == "viewer"
  def can_edit? = !viewer?
  def first_name = name.split.first

  # nome sem acento e em minúsculas, para as menções (@maria) nos comentários
  def mention_handle
    name.split.first.unicode_normalize(:nfd).gsub(/\p{Mn}/, "").downcase
  end
end
