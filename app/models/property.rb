class Property < ApplicationRecord
  belongs_to :host, class_name: "User"
  belongs_to :neighborhood

  has_many :rooms, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :property_amenities, dependent: :destroy
  has_many :amenities, through: :property_amenities

  validates :address, presence: true
  validates :description, presence: true

  scope :in_neighborhood, ->(neighborhood_id) { where(neighborhood_id: neighborhood_id) }
end
