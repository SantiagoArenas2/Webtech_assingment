class User < ApplicationRecord
  has_many :properties, foreign_key: :host_id, inverse_of: :host, dependent: :destroy
  has_many :applications, foreign_key: :seeker_id, inverse_of: :seeker, dependent: :destroy
  has_many :reviews, foreign_key: :author_id, inverse_of: :author, dependent: :destroy
  has_many :saved_listings, foreign_key: :seeker_id, inverse_of: :seeker, dependent: :destroy
  has_many :saved_rooms, through: :saved_listings, source: :room
  has_many :reports, foreign_key: :reporter_id, inverse_of: :reporter, dependent: :destroy
  has_many :resolved_reports, class_name: "Report", foreign_key: :resolver_id, inverse_of: :resolver

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
                     format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password_hash, presence: true

  scope :moderators, -> { where(is_moderator: true) }
end
