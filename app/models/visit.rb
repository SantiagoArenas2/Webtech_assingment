class Visit < ApplicationRecord
  belongs_to :application
  has_one :review, dependent: :destroy

  enum :status, {
    proposed: "proposed", scheduled: "scheduled", confirmed: "confirmed",
    rescheduled: "rescheduled", completed: "completed", cancelled: "cancelled"
  }

  validates :scheduled_at, presence: true
  validate :scheduled_in_future
  validate :application_is_shortlisted, on: :create
  validate :valid_status_transition
  validates :application_id, uniqueness: true

  private

  def scheduled_in_future
    return if scheduled_at.blank? || application.blank?

    errors.add(:scheduled_at, "cannot be in the past") if scheduled_at < Time.current && !completed? && !cancelled?
  end

  def application_is_shortlisted
    errors.add(:application, "must be shortlisted before proposing a visit") unless application&.shortlisted?
  end

  def valid_status_transition
    return unless will_save_change_to_status?
    return if new_record? && proposed?

    allowed = {
      "proposed" => %w[confirmed rescheduled cancelled],
      "scheduled" => %w[confirmed rescheduled cancelled completed],
      "confirmed" => %w[rescheduled cancelled completed],
      "rescheduled" => %w[confirmed rescheduled cancelled completed],
      "completed" => [],
      "cancelled" => []
    }
    errors.add(:status, "transition is not allowed") unless allowed.fetch(status_in_database, []).include?(status)
  end
end
