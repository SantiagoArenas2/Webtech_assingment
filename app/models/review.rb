class Review < ApplicationRecord
  belongs_to :property
  belongs_to :author, class_name: "User"

  validates :rating, presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :comment, length: { maximum: 2000 }, allow_blank: true
end
