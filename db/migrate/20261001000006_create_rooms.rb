class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.references :property, null: false, foreign_key: true
      t.string :label, null: false
      t.integer :price, null: false
      t.integer :deposit
      t.integer :minimum_stay_months
      t.date :available_from, null: false
      t.string :status, null: false, default: "available"
      t.text :description

      t.timestamps
    end
  end
end
