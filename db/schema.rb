# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_05_164727) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "supplier_id"
    t.bigint "recipient_id"
    t.string "number", null: false
    t.string "arrears", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["recipient_id"], name: "index_accounts_on_recipient_id"
    t.index ["supplier_id"], name: "index_accounts_on_supplier_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "cases", force: :cascade do |t|
    t.bigint "recipient_id", null: false
    t.datetime "completed_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "enroller_id", null: false
    t.integer "status", default: 0
    t.bigint "supplier_id", null: false
    t.string "account_number", null: false
    t.string "account_arrears", null: false
    t.index ["enroller_id"], name: "index_cases_on_enroller_id"
    t.index ["recipient_id"], name: "index_cases_on_recipient_id"
    t.index ["status"], name: "index_cases_on_status"
    t.index ["supplier_id"], name: "index_cases_on_supplier_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "source_url", null: false
    t.bigint "recipient_id", null: false
    t.index ["recipient_id"], name: "index_documents_on_recipient_id"
    t.index ["source_url"], name: "index_documents_on_source_url", unique: true
  end

  create_table "enrollers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "households", force: :cascade do |t|
    t.bigint "recipient_id"
    t.string "size"
    t.jsonb "income_history"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["recipient_id"], name: "index_households_on_recipient_id"
  end

  create_table "recipients", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone_number", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "street", null: false
    t.string "street2"
    t.string "city", null: false
    t.string "state", null: false
    t.string "zip", null: false
    t.string "dhs_number"
    t.string "dhs_household_size"
    t.string "dhs_household_income"
    t.index ["phone_number"], name: "index_recipients_on_phone_number", unique: true
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "organization_type", null: false
    t.bigint "organization_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["organization_type", "organization_id"], name: "index_users_on_organization_type_and_organization_id"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
