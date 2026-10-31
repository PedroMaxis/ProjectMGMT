# Documentação em páginas aninhadas (estilo wiki), em Markdown. Pertence a um projeto OU a um produto.
class Page < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :product, optional: true
  belongs_to :parent, class_name: "Page", optional: true
  belongs_to :author, class_name: "User", optional: true
  has_many :children, -> { order(:position, :title) }, class_name: "Page", foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  validates :title, presence: true, length: { maximum: 120 }
  validate :belongs_to_exactly_one_space
  validate :parent_in_same_space, :no_cycles

  scope :roots, -> { where(parent_id: nil).order(:position, :title) }

  def space = project || product

  def ancestors
    cadeia = []
    atual = parent
    while atual && cadeia.size < 20
      cadeia.unshift(atual)
      atual = atual.parent
    end
    cadeia
  end

  def descendant_ids
    children.flat_map { |c| [ c.id ] + c.descendant_ids }
  end

  private

  def belongs_to_exactly_one_space
    errors.add(:base, :one_space) unless project_id.present? ^ product_id.present?
  end

  def parent_in_same_space
    return unless parent
    errors.add(:parent_id, :other_space) if parent.project_id != project_id || parent.product_id != product_id
  end

  def no_cycles
    return unless parent_id && persisted?
    errors.add(:parent_id, :cycle) if parent_id == id || descendant_ids.include?(parent_id)
  end
end
