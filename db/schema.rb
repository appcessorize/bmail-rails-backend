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

ActiveRecord::Schema[8.1].define(version: 2026_01_04_202237) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "entries", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_entries_on_user_id"
  end

  create_table "focus_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_minutes", null: false
    t.datetime "ended_at"
    t.datetime "started_at", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["started_at"], name: "index_focus_sessions_on_started_at"
    t.index ["user_id", "status"], name: "index_focus_sessions_on_user_id_and_status"
    t.index ["user_id"], name: "index_focus_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "apple_user_id"
    t.string "auth_token"
    t.datetime "created_at", null: false
    t.string "email"
    t.integer "failed_login_attempts", default: 0, null: false
    t.boolean "image_public", default: false, null: false
    t.datetime "locked_until"
    t.string "page_slug", limit: 16
    t.string "password_digest"
    t.datetime "shame_activated_at"
    t.boolean "shame_active", default: false, null: false
    t.string "token_digest"
    t.datetime "token_expires_at"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["apple_user_id"], name: "index_users_on_apple_user_id"
    t.index ["page_slug"], name: "index_users_on_page_slug", unique: true
    t.index ["token_digest"], name: "index_users_on_token_digest", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "entries", "users"
  add_foreign_key "focus_sessions", "users"
end
