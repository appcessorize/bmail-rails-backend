class User < ApplicationRecord
  include SecurityAuditable

  has_secure_password

  has_many :entries, dependent: :destroy
  has_one_attached :profile_image do |attachable|
    attachable.variant :thumb, resize_to_limit: [200, 200]
  end

  before_create :generate_auth_token

  validate :profile_image_validation

  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :auth_token, uniqueness: true

  TOKEN_EXPIRATION = 30.days

  # Generate a new auth token and hash it
  def generate_auth_token
    self.auth_token = SecureRandom.hex(32)

    # Only set token_digest if column exists (for backward compatibility)
    if self.class.column_names.include?('token_digest')
      self.token_digest = Digest::SHA256.hexdigest(auth_token)
      self.token_expires_at = TOKEN_EXPIRATION.from_now if self.class.column_names.include?('token_expires_at')
    end
  end

  # Verify if a token is valid and not expired
  def self.find_by_valid_token(token)
    return nil if token.blank?

    # Support both old auth_token and new token_digest lookup
    if column_names.include?('token_digest')
      digest = Digest::SHA256.hexdigest(token)
      user = find_by(token_digest: digest)

      return nil unless user
      return nil if user.token_expires_at && user.token_expires_at < Time.current
    else
      # Fallback for old auth_token column
      user = find_by(auth_token: token)
    end

    user
  end

  # Check if token is expired
  def token_expired?
    token_expires_at && token_expires_at < Time.current
  end

  private

  def profile_image_validation
    return unless profile_image.attached?

    # Validate content type
    unless profile_image.content_type.in?(%w[image/jpeg image/jpg image/png image/gif])
      errors.add(:profile_image, 'must be a JPEG, PNG, or GIF')
    end

    # Validate file size (5MB max)
    if profile_image.byte_size > 5.megabytes
      errors.add(:profile_image, 'size must be less than 5MB')
    end
  end
end
