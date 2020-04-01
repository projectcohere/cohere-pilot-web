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

ActiveRecord::Schema.define(version: 2020_04_01_154237) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "case_assignments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "case_id", null: false
    t.bigint "partner_id", null: false
    t.index ["case_id"], name: "index_case_assignments_on_case_id"
    t.index ["partner_id"], name: "index_case_assignments_on_partner_id"
    t.index ["user_id", "case_id", "partner_id"], name: "by_natural_key", unique: true
    t.index ["user_id"], name: "index_case_assignments_on_user_id"
  end

  create_table "cases", force: :cascade do |t|
    t.bigint "recipient_id", null: false
    t.datetime "completed_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "enroller_id", null: false
    t.integer "status", default: 0
    t.bigint "supplier_id", null: false
    t.string "supplier_account_number"
    t.integer "supplier_account_arrears_cents"
    t.datetime "received_message_at", precision: 6
    t.integer "program", default: 0
    t.bigint "referrer_id"
    t.boolean "supplier_account_active_service", default: true, null: false
    t.boolean "has_new_activity", default: false, null: false
    t.index ["enroller_id"], name: "index_cases_on_enroller_id"
    t.index ["recipient_id"], name: "index_cases_on_recipient_id"
    t.index ["referrer_id"], name: "index_cases_on_referrer_id"
    t.index ["status"], name: "index_cases_on_status"
    t.index ["supplier_id"], name: "index_cases_on_supplier_id"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.string "body"
    t.string "sender", null: false
    t.bigint "chat_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chat_id"], name: "index_chat_messages_on_chat_id"
  end

  create_table "chats", force: :cascade do |t|
    t.bigint "recipient_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "session_token"
    t.index ["recipient_id"], name: "index_chats_on_recipient_id", unique: true
    t.index ["session_token"], name: "index_chats_on_session_token", unique: true
    t.index ["updated_at"], name: "index_chats_on_updated_at"
  end

  create_table "documents", force: :cascade do |t|
    t.string "source_url"
    t.bigint "case_id", null: false
    t.integer "classification", default: 0
    t.index ["case_id"], name: "index_documents_on_case_id"
    t.index ["classification"], name: "index_documents_on_classification"
  end

  create_table "partners", force: :cascade do |t|
    t.string "name", null: false
    t.integer "membership", null: false
    t.integer "programs", array: true
    t.index ["membership"], name: "index_partners_on_membership"
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
    t.integer "household_size"
    t.integer "household_income_cents"
    t.integer "household_ownership", default: 0, null: false
    t.boolean "household_primary_residence", default: true, null: false
    t.index ["phone_number"], name: "index_recipients_on_phone_number", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "partner_id", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["partner_id"], name: "index_users_on_partner_id"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
