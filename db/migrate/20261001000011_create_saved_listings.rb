class CreateSavedListings < ActiveRecord::Migration[8.0]
  def change
    create_table :saved_listings do |t|
      t.references :seeker, null: false, foreign_key: { to_table: :users }
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
    add_index :saved_listings, [:seeker_id, :room_id], unique: true
  end
end
