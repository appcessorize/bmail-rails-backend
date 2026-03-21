class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.string :page_slug, null: false
      t.string :reason, null: false
      t.text :details
      t.string :reporter_ip
      t.boolean :resolved, default: false, null: false

      t.timestamps
    end

    add_index :reports, :page_slug
    add_index :reports, :resolved
  end
end
