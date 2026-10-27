class Application < ApplicationRecord
  belongs_to :room
  belongs_to :seeker, class_name: "User"
  has_one :visit, dependent: :destroy

  enum :status, {
    pending: "pending",
    shortlisted: "shortlisted",
    accepted: "accepted",
    rejected: "rejected",
    withdrawn: "withdrawn"
  }

  validates :message, presence: true
  validates :seeker_id, uniqueness: { scope: :room_id, message: "has already applied to this room" }
  validates :move_in_date, presence: true
  validates :intended_stay_months, numericality: { only_integer: true, greater_than: 0 }
  validate :eligible_to_apply, on: :create
  validate :valid_status_change

  scope :pending_answer, -> { where(status: [:pending, :shortlisted]) }

  def accept!
    self.class.transaction do
      room.lock!
      unless room.published? && (pending? || shortlisted?)
        errors.add(:status, "cannot be accepted in its current state")
        raise ActiveRecord::RecordInvalid, self
      end

      self.class.where(room_id: room_id, status: %w[pending shortlisted])
                .where.not(id: id).update_all(status: "rejected", updated_at: Time.current)
      @accepting = true
      update!(status: :accepted)
      room.reserve_for_accepted_application!
    end
  ensure
    @accepting = false
  end

  private

  def eligible_to_apply
    room.lock! if room&.persisted?
    errors.add(:room, "is not accepting applications") unless room&.published?
    errors.add(:seeker, "cannot apply to their own listing") if room&.property&.host_id == seeker_id
    if room && seeker_id && self.class.where(room_id: room_id, seeker_id: seeker_id).where.not(id: id).exists?
      errors.add(:seeker_id, "has already applied to this listing")
    end
  end

  def valid_status_change
    return unless will_save_change_to_status?

    if new_record? && !pending?
      errors.add(:status, "must start as pending")
      return
    end
    return if new_record?

    previous_status = status_in_database
    allowed = {
      "pending" => %w[shortlisted rejected withdrawn accepted],
      "shortlisted" => %w[rejected withdrawn accepted],
      "accepted" => [],
      "rejected" => [],
      "withdrawn" => []
    }
    unless allowed.fetch(previous_status, []).include?(status)
      errors.add(:status, "transition is not allowed")
      return
    end

    if accepted? && (!@accepting || !room&.published? ||
                     self.class.where(room_id: room_id, status: "accepted").where.not(id: id).exists?)
      errors.add(:status, "cannot be accepted for this listing")
    end
    if withdrawn? && !(status_in_database.in?(%w[pending shortlisted]))
      errors.add(:status, "can only be withdrawn while pending or shortlisted")
    end
  end
end
