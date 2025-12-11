class AddPageSlugAndShameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :page_slug, :string, limit: 10
    add_column :users, :shame_active, :boolean, default: false, null: false
    add_column :users, :shame_activated_at, :datetime

    add_index :users, :page_slug, unique: true
  end
end
