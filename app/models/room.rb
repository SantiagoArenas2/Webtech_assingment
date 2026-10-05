class Room < ApplicationRecord
  belongs_to :property

  has_many :room_photos, -> { order(:sort_order) }, dependent: :destroy
  has_many :applications, dependent: :destroy
  has_many :saved_listings, dependent: :destroy
  has_many :reports, dependent: :destroy

  enum :status, { available: "available", rented: "rented", inactive: "inactive" }

  validates :label, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :minimum_stay_months, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :available_from, presence: true
  validate :available_from_cannot_be_in_the_past, on: :create

  scope :published, -> { where(status: :available) }
  scope :available_from_date, ->(date) { where("available_from <= ?", date) }
  scope :under_rent, ->(amount) { where("price <= ?", amount) }

  private

  def available_from_cannot_be_in_the_past
    return if available_from.blank?

    errors.add(:available_from, "can't be in the past") if available_from < Date.current
  end
end
