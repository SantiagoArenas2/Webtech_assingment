class Application < ApplicationRecord
  belongs_to :room
  belongs_to :seeker, class_name: "User"
  has_one :visit, dependent: :destroy

  enum :status, {
    submitted: "submitted",
    shortlisted: "shortlisted",
    accepted: "accepted",
    rejected: "rejected",
    withdrawn: "withdrawn"
  }

  validates :message, presence: true
  validates :seeker_id, uniqueness: { scope: :room_id, message: "has already applied to this room" }

  scope :pending_answer, -> { where(status: [:submitted, :shortlisted]) }
end
