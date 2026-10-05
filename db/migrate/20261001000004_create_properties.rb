class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :properties do |t|
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.references :neighborhood, null: false, foreign_key: true
      t.string :address, null: false
      t.text :description

      t.timestamps
    end
  end
end
