class PageWatcher < ApplicationRecord
  validates :page_slug, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :page_slug, message: "is already watching this page" }
  validates :unsubscribe_token, presence: true, uniqueness: true

  before_validation :generate_unsubscribe_token, on: :create

  scope :for_slug, ->(slug) { where(page_slug: slug) }

  private

  def generate_unsubscribe_token
    self.unsubscribe_token ||= SecureRandom.urlsafe_base64(32)
  end
end
