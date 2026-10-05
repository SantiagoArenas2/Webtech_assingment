class PropertyAmenity < ApplicationRecord
  belongs_to :property
  belongs_to :amenity

  validates :property_id, uniqueness: { scope: :amenity_id }
end
