class AddAppleUserIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :apple_user_id, :string
    add_index :users, :apple_user_id
  end
end
