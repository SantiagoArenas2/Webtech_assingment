class RoomPhoto < ApplicationRecord
  belongs_to :room

  validates :url, presence: true
  validates :sort_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
