class Comment < ApplicationRecord
  belongs_to :issue
  belongs_to :user

  validates :body, presence: true, length: { maximum: 5000 }

  after_create_commit { Event.record!(issue: issue, user: user, kind: "commented", details: { comment_id: id }) }
end
