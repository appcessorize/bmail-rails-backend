class AddTokenDigestAndExpirationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :token_digest, :string
    add_column :users, :token_expires_at, :datetime
    add_index :users, :token_digest, unique: true
  end
end
