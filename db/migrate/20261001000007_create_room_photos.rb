class CreateRoomPhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :room_photos do |t|
      t.references :room, null: false, foreign_key: true
      t.string :url, null: false
      t.integer :sort_order, null: false, default: 0

      t.timestamps
    end
  end
end
