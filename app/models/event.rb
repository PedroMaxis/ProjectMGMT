# Histórico de tudo que acontece nas tarefas: quem fez o quê e quando. Alimenta a linha do tempo e o feed de atividade.
class Event < ApplicationRecord
  KINDS = %w[created status_changed assigned priority_changed sprint_changed estimate_changed title_changed commented].freeze

  belongs_to :project
  belongs_to :issue, optional: true
  belongs_to :user, optional: true

  serialize :details, coder: JSON, type: Hash

  validates :kind, inclusion: { in: KINDS }

  scope :recent, -> { order(created_at: :desc, id: :desc) }

  def self.record!(issue:, kind:, user: Current.user, details: {})
    create!(project: issue.project, issue: issue, user: user, kind: kind, details: details, created_at: Time.current)
  end
end
