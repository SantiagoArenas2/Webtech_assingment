class CreateApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :applications do |t|
      t.references :room, null: false, foreign_key: true
      t.references :seeker, null: false, foreign_key: { to_table: :users }
      t.text :message, null: false
      t.string :status, null: false, default: "submitted"

      t.timestamps
    end
    add_index :applications, [:room_id, :seeker_id], unique: true
  end
end
