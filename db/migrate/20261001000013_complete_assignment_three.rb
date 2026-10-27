class CompleteAssignmentThree < ActiveRecord::Migration[8.0]
  def up
    add_column :properties, :property_type, :string, null: false, default: "house"
    add_column :properties, :bedrooms, :integer, null: false, default: 1
    add_column :properties, :bathrooms, :integer, null: false, default: 1
    add_column :properties, :shared_spaces, :text
    add_column :rooms, :furnished, :boolean, null: false, default: false
    add_column :rooms, :private_bathroom, :boolean, null: false, default: false
    change_column_default :rooms, :status, from: "available", to: "draft"
    change_column_default :applications, :status, from: "submitted", to: "pending"
    change_column_default :visits, :status, from: "scheduled", to: "proposed"
    add_column :applications, :move_in_date, :date, null: false, default: -> { "CURRENT_DATE" }
    add_column :applications, :intended_stay_months, :integer, null: false, default: 1
    execute <<~SQL
      UPDATE applications
      SET move_in_date = rooms.available_from,
          intended_stay_months = COALESCE(rooms.minimum_stay_months, 1)
      FROM rooms
      WHERE applications.room_id = rooms.id
    SQL
    change_column_default :applications, :move_in_date, from: -> { "CURRENT_DATE" }, to: nil
    change_column_default :applications, :intended_stay_months, from: 1, to: nil
    add_index :applications, :room_id, unique: true, where: "status = 'accepted'",
              name: :index_applications_one_accepted_per_room
    remove_index :visits, name: :index_visits_on_application_id
    add_index :visits, :application_id, unique: true, name: :index_visits_on_application_id
    add_column :reviews, :visit_id, :bigint
    add_index :reviews, :visit_id, unique: true
    add_foreign_key :reviews, :visits

    execute "UPDATE rooms SET status = 'published' WHERE status = 'available'"
    execute "UPDATE rooms SET status = 'withdrawn' WHERE status = 'inactive'"
    execute "UPDATE applications SET status = 'pending' WHERE status = 'submitted'"

    create_table :active_storage_blobs do |t|
      t.string :key, null: false
      t.string :filename, null: false
      t.string :content_type
      t.text :metadata
      t.string :service_name, null: false
      t.bigint :byte_size, null: false
      t.string :checksum
      t.datetime :created_at, null: false
      t.index :key, unique: true
    end

    create_table :active_storage_attachments do |t|
      t.string :name, null: false
      t.references :record, null: false, polymorphic: true, index: false
      t.references :blob, null: false, foreign_key: { to_table: :active_storage_blobs }
      t.datetime :created_at, null: false
      t.index [:record_type, :record_id, :name, :blob_id],
              name: :index_active_storage_attachments_uniqueness, unique: true
    end

    create_table :active_storage_variant_records do |t|
      t.belongs_to :blob, null: false, index: false, foreign_key: { to_table: :active_storage_blobs }
      t.string :variation_digest, null: false
      t.index [:blob_id, :variation_digest],
              name: :index_active_storage_variant_records_uniqueness, unique: true
    end

    create_table :action_text_rich_texts do |t|
      t.string :name, null: false
      t.text :body
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index [:record_type, :record_id, :name],
              name: :index_action_text_rich_texts_uniqueness, unique: true
    end

    execute <<~SQL
      INSERT INTO action_text_rich_texts (name, body, record_type, record_id, created_at, updated_at)
      SELECT 'description', rooms.description, 'Room', rooms.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM rooms
      WHERE rooms.description IS NOT NULL AND rooms.description <> ''
    SQL
    remove_column :rooms, :description
  end

  def down
    execute "UPDATE rooms SET status = 'available' WHERE status IN ('draft', 'published', 'reserved')"
    execute "UPDATE rooms SET status = 'inactive' WHERE status = 'withdrawn'"
    execute "UPDATE applications SET status = 'submitted' WHERE status = 'pending'"
    execute "UPDATE visits SET status = 'scheduled' WHERE status IN ('proposed', 'confirmed', 'rescheduled')"
    add_column :rooms, :description, :text
    execute <<~SQL
      UPDATE rooms
      SET description = action_text_rich_texts.body
      FROM action_text_rich_texts
      WHERE action_text_rich_texts.record_type = 'Room'
        AND action_text_rich_texts.record_id = rooms.id
        AND action_text_rich_texts.name = 'description'
    SQL
    drop_table :action_text_rich_texts
    drop_table :active_storage_variant_records
    drop_table :active_storage_attachments
    drop_table :active_storage_blobs
    remove_foreign_key :reviews, :visits
    remove_index :reviews, :visit_id
    remove_column :reviews, :visit_id
    remove_column :applications, :intended_stay_months
    remove_column :applications, :move_in_date
    remove_index :visits, name: :index_visits_on_application_id
    add_index :visits, :application_id
    remove_index :applications, name: :index_applications_one_accepted_per_room
    remove_column :rooms, :private_bathroom
    remove_column :rooms, :furnished
    remove_column :properties, :shared_spaces
    remove_column :properties, :bathrooms
    remove_column :properties, :bedrooms
    remove_column :properties, :property_type
    change_column_default :applications, :status, from: "pending", to: "submitted"
    change_column_default :visits, :status, from: "proposed", to: "scheduled"
    change_column_default :rooms, :status, from: "draft", to: "available"
  end
end
