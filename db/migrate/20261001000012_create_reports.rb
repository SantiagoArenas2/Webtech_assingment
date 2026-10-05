class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :room, null: false, foreign_key: true
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.text :reason, null: false
      t.string :status, null: false, default: "pending"
      t.references :resolver, foreign_key: { to_table: :users }
      t.datetime :resolved_at

      t.timestamps
    end
  end
end
