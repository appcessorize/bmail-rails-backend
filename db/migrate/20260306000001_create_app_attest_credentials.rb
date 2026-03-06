class CreateAppAttestCredentials < ActiveRecord::Migration[8.1]
  def change
    create_table :app_attest_credentials do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :key_id, null: false
      t.binary :public_key, null: false
      t.binary :receipt
      t.integer :sign_count, default: 0, null: false
      t.string :environment, default: "production"
      t.timestamps
    end
    add_index :app_attest_credentials, :key_id, unique: true
  end
end
