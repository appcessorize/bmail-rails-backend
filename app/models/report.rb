class Report < ApplicationRecord
  VALID_REASONS = %w[inappropriate illegal harassment other].freeze

  validates :page_slug, presence: true
  validates :reason, presence: true, inclusion: { in: VALID_REASONS }
  validates :details, length: { maximum: 2000 }, allow_blank: true

  scope :unresolved, -> { where(resolved: false) }
  scope :recent, -> { order(created_at: :desc) }
end
