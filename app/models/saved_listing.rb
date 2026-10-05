class SavedListing < ApplicationRecord
  belongs_to :seeker, class_name: "User"
  belongs_to :room

  validates :seeker_id, uniqueness: { scope: :room_id }
end
