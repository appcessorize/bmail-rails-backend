class AppAttestCredential < ApplicationRecord
  belongs_to :user

  validates :key_id, presence: true, uniqueness: true
  validates :public_key, presence: true
end
