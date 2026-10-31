# Um produto é algo que evolui por anos: tem visão, versões (releases) e projetos que entregam partes dele.
class Product < ApplicationRecord
  STATUSES = %w[active paused archived].freeze

  belongs_to :owner, class_name: "User", optional: true
  has_many :releases, -> { order(target_date: :desc, id: :desc) }, dependent: :destroy
  has_many :projects, dependent: :nullify
  has_many :pages, dependent: :destroy
  has_many :issues, through: :projects

  before_validation :set_slug, on: :create

  validates :name, presence: true, length: { maximum: 80 }
  validates :slug, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  scope :visible, -> { where.not(status: "archived") }

  def to_param = slug

  # andamento geral: pontos concluídos / pontos totais de todos os projetos do produto
  def progress
    total = issues.work.sum("COALESCE(estimate, 1)")
    return 0 if total.zero?
    (issues.work.done.sum("COALESCE(estimate, 1)") * 100.0 / total).round
  end

  private

  def set_slug
    base = name.to_s.parameterize.presence || "produto"
    self.slug ||= base
    n = 2
    while Product.exists?(slug: slug)
      self.slug = "#{base}-#{n}"
      n += 1
    end
  end
end
