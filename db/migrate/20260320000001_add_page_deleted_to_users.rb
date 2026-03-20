class AddPageDeletedToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :page_deleted, :boolean, default: false, null: false
  end
end
