class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_digest&.last(10)
  end

  enum :role, { member: "member", moderator: "moderator" }, default: :member

  has_many :properties, foreign_key: :host_id, inverse_of: :host, dependent: :destroy
  has_many :applications, foreign_key: :seeker_id, inverse_of: :seeker, dependent: :destroy
  has_many :reviews, foreign_key: :author_id, inverse_of: :author, dependent: :destroy
  has_many :saved_listings, foreign_key: :seeker_id, inverse_of: :seeker, dependent: :destroy
  has_many :saved_rooms, through: :saved_listings, source: :room
  has_many :reports, foreign_key: :reporter_id, inverse_of: :reporter, dependent: :destroy
  has_many :resolved_reports, class_name: "Report", foreign_key: :resolver_id, inverse_of: :resolver

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :bio, length: { maximum: 500 }, allow_blank: true

  scope :moderators, -> { where(role: :moderator) }
end
