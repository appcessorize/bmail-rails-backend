class Entry < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :body, presence: true

  before_save :sanitize_content

  private

  def sanitize_content
    self.title = ActionController::Base.helpers.strip_tags(title) if title.present?
    self.body = ActionController::Base.helpers.strip_tags(body) if body.present?
  end
end
