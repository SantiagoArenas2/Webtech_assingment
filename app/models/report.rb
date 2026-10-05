class Report < ApplicationRecord
  belongs_to :room
  belongs_to :reporter, class_name: "User"
  belongs_to :resolver, class_name: "User", optional: true

  enum :status, { pending: "pending", dismissed: "dismissed", actioned: "actioned" }

  validates :reason, presence: true

  scope :pending_review, -> { where(status: :pending) }
end
