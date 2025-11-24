class AddImagePublicToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :image_public, :boolean, default: false, null: false
  end
end
