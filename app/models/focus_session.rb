class FocusSession < ApplicationRecord
  belongs_to :user

  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :started_at, presence: true
  validates :status, presence: true, inclusion: { in: %w[active completed failed] }

  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  scope :recent, -> { order(created_at: :desc) }

  # Complete the session successfully
  def complete!
    update!(status: 'completed', ended_at: Time.current)
  end

  # Mark the session as failed and activate shame
  def fail!
    transaction do
      update!(status: 'failed', ended_at: Time.current)
      user.activate_shame!
    end
  end

  # Check if session is still active
  def active?
    status == 'active'
  end

  # Check if session has expired (past its duration)
  def expired?
    return false unless active?
    started_at + duration_minutes.minutes < Time.current
  end
end
