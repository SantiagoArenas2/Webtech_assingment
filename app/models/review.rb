class Review < ApplicationRecord
  belongs_to :property
  belongs_to :author, class_name: "User"
  belongs_to :visit, optional: true

  validates :visit_id, uniqueness: true, allow_nil: true
  validate :visit_was_completed_for_author, if: -> { visit_id.present? || new_record? }
  validates :rating, presence: true,
                      numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :comment, length: { maximum: 2000 }, allow_blank: true

  private

  def visit_was_completed_for_author
    if visit.blank?
      errors.add(:visit, "must be completed") if new_record?
      return
    end

    errors.add(:visit, "must be completed") unless visit.completed?
    errors.add(:author, "must be the applicant") unless visit.application.seeker_id == author_id
    errors.add(:property, "must match the visited listing") unless visit.application.room.property_id == property_id
  end
end
