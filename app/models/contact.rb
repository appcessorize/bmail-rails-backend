class Contact < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { minimum: 10, maximum: 5000 }

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }
end
