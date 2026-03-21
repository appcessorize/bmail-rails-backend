class CreatePageWatchers < ActiveRecord::Migration[8.1]
  def change
    create_table :page_watchers do |t|
      t.string :page_slug, null: false
      t.string :email, null: false
      t.boolean :confirmed, default: false, null: false
      t.string :unsubscribe_token, null: false

      t.timestamps
    end

    add_index :page_watchers, [:page_slug, :email], unique: true
    add_index :page_watchers, :unsubscribe_token, unique: true
  end
end
