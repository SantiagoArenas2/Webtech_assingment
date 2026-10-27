class Room < ApplicationRecord
  belongs_to :property

  has_many_attached :photographs
  has_rich_text :description
  has_rich_text :house_rules
  has_many :room_photos, -> { order(:sort_order) }, dependent: :destroy
  has_many :applications, dependent: :destroy
  has_many :saved_listings, dependent: :destroy
  has_many :reports, dependent: :destroy

  enum :status, {
    draft: "draft", published: "published", reserved: "reserved",
    rented: "rented", withdrawn: "withdrawn"
  }

  validates :label, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :minimum_stay_months, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :available_from, presence: true
  validate :photographs_are_supported_images_within_size_limit
  before_validation :start_as_draft, on: :create
  validate :valid_status_transition
  validate :available_from_cannot_be_in_the_past, on: :create

  scope :published, -> { where(status: :published) }
  scope :available_from_date, ->(date) { where("available_from <= ?", date) }
  scope :under_rent, ->(amount) { where("price <= ?", amount) }

  def publish!
    transition_to!(:published, from: :draft)
  end

  def withdraw!
    transition_to!(:withdrawn, from: [:published, :reserved])
  end

  def mark_rented!
    transition_to!(:rented, from: :reserved)
  end

  def reserve_for_accepted_application!
    @acceptance_reservation = true
    update!(status: :reserved)
  ensure
    @acceptance_reservation = false
  end

  private

  def transition_to!(target, from:)
    allowed_sources = Array(from).map(&:to_s)
    unless allowed_sources.include?(status)
      errors.add(:status, "cannot transition from #{status.humanize} to #{target.to_s.humanize}")
      raise ActiveRecord::RecordInvalid, self
    end

    update!(status: target)
  end

  def start_as_draft
    self.status = :draft
  end

  def valid_status_transition
    return if new_record? && draft?
    return unless will_save_change_to_status?

    allowed = {
      "draft" => %w[published withdrawn],
      "published" => %w[reserved withdrawn],
      "reserved" => %w[rented withdrawn],
      "rented" => [],
      "withdrawn" => []
    }
    previous = status_in_database
    return if allowed.fetch(previous, []).include?(status) &&
              (status != "reserved" || @acceptance_reservation)

    errors.add(:status, "transition is not allowed")
  end

  def available_from_cannot_be_in_the_past
    return if available_from.blank?

    errors.add(:available_from, "can't be in the past") if available_from < Date.current
  end

  def photographs_are_supported_images_within_size_limit
    supported_types = %w[image/png image/jpeg image/webp image/gif]
    photographs.each do |photograph|
      errors.add(:photographs, "must be PNG, JPEG, WebP, or GIF images") unless supported_types.include?(photograph.blob.content_type)
      errors.add(:photographs, "must be 10 MB or smaller") if photograph.blob.byte_size > 10.megabytes
    end
  end
end
