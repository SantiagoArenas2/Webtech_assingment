class Visit < ApplicationRecord
  belongs_to :application

  enum :status, { scheduled: "scheduled", completed: "completed", cancelled: "cancelled" }

  validates :scheduled_at, presence: true
  validate :scheduled_after_application_created

  private

  def scheduled_after_application_created
    return if scheduled_at.blank? || application.blank?

    if scheduled_at < application.created_at
      errors.add(:scheduled_at, "must be after the application was created")
    end
  end
end
