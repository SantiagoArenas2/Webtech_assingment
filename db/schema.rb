# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_10_01_000012) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "amenities", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_amenities_on_name", unique: true
  end

  create_table "applications", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.bigint "seeker_id", null: false
    t.text "message", null: false
    t.string "status", default: "submitted", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id", "seeker_id"], name: "index_applications_on_room_id_and_seeker_id", unique: true
    t.index ["room_id"], name: "index_applications_on_room_id"
    t.index ["seeker_id"], name: "index_applications_on_seeker_id"
  end

  create_table "neighborhoods", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_neighborhoods_on_name", unique: true
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "host_id", null: false
    t.bigint "neighborhood_id", null: false
    t.string "address", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["host_id"], name: "index_properties_on_host_id"
    t.index ["neighborhood_id"], name: "index_properties_on_neighborhood_id"
  end

  create_table "property_amenities", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "amenity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amenity_id"], name: "index_property_amenities_on_amenity_id"
    t.index ["property_id", "amenity_id"], name: "index_property_amenities_on_property_id_and_amenity_id", unique: true
    t.index ["property_id"], name: "index_property_amenities_on_property_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.bigint "reporter_id", null: false
    t.text "reason", null: false
    t.string "status", default: "pending", null: false
    t.bigint "resolver_id"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
    t.index ["resolver_id"], name: "index_reports_on_resolver_id"
    t.index ["room_id"], name: "index_reports_on_room_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "author_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_reviews_on_author_id"
    t.index ["property_id"], name: "index_reviews_on_property_id"
  end

  create_table "room_photos", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.string "url", null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_room_photos_on_room_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.string "label", null: false
    t.integer "price", null: false
    t.integer "deposit"
    t.integer "minimum_stay_months"
    t.date "available_from", null: false
    t.string "status", default: "available", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_rooms_on_property_id"
  end

  create_table "saved_listings", force: :cascade do |t|
    t.bigint "seeker_id", null: false
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_saved_listings_on_room_id"
    t.index ["seeker_id", "room_id"], name: "index_saved_listings_on_seeker_id_and_room_id", unique: true
    t.index ["seeker_id"], name: "index_saved_listings_on_seeker_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_hash", null: false
    t.boolean "is_moderator", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "scheduled_at", null: false
    t.string "status", default: "scheduled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_visits_on_application_id"
  end

  add_foreign_key "applications", "rooms"
  add_foreign_key "applications", "users", column: "seeker_id"
  add_foreign_key "properties", "neighborhoods"
  add_foreign_key "properties", "users", column: "host_id"
  add_foreign_key "property_amenities", "amenities"
  add_foreign_key "property_amenities", "properties"
  add_foreign_key "reports", "rooms"
  add_foreign_key "reports", "users", column: "reporter_id"
  add_foreign_key "reports", "users", column: "resolver_id"
  add_foreign_key "reviews", "properties"
  add_foreign_key "reviews", "users", column: "author_id"
  add_foreign_key "room_photos", "rooms"
  add_foreign_key "rooms", "properties"
  add_foreign_key "saved_listings", "rooms"
  add_foreign_key "saved_listings", "users", column: "seeker_id"
  add_foreign_key "visits", "applications"
end
