class CreateFocusSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :focus_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :duration_minutes, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.string :status, default: 'active', null: false  # active, completed, failed

      t.timestamps
    end

    add_index :focus_sessions, [:user_id, :status]
    add_index :focus_sessions, :started_at
  end
end
