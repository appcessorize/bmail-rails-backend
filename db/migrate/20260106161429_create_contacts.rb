class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.string :email, null: false
      t.text :message, null: false
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
