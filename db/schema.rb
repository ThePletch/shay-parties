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

ActiveRecord::Schema[7.1].define(version: 2025_07_27_234627) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "street"
    t.string "street2"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.decimal "latitude", precision: 15, scale: 10
    t.decimal "longitude", precision: 15, scale: 10
    t.text "verification_info"
    t.text "original_attributes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "attendances", force: :cascade do |t|
    t.integer "event_id"
    t.integer "attendee_id"
    t.string "invitation_token"
    t.string "invitation_key"
    t.string "rsvp_status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "attendee_type", null: false
    t.bigint "attendance_id"
    t.index ["attendance_id"], name: "index_attendances_on_attendance_id"
    t.index ["attendee_id"], name: "index_attendances_on_attendee_id"
    t.index ["event_id", "attendee_id", "attendee_type"], name: "index_attendances_on_event_id_and_attendee_id_and_attendee_type", unique: true
    t.index ["event_id"], name: "index_attendances_on_event_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "creator_type"
    t.bigint "creator_id"
    t.string "editor_type"
    t.bigint "editor_id"
    t.bigint "parent_id"
    t.text "body"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "event_id"
    t.index ["creator_type", "creator_id"], name: "index_comments_on_creator"
    t.index ["editor_type", "editor_id"], name: "index_comments_on_editor"
    t.index ["event_id"], name: "index_comments_on_event_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.datetime "start_time", precision: nil
    t.datetime "end_time", precision: nil
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.bigint "address_id"
    t.boolean "secret", default: false
    t.string "slug"
    t.integer "photo_crop_y_offset", default: 0, null: false
    t.boolean "requires_testing", default: false, null: false
    t.integer "plus_one_max", default: -1, null: false
    t.index ["address_id"], name: "index_events_on_address_id"
    t.index ["slug"], name: "index_events_on_slug", unique: true
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "guests", force: :cascade do |t|
    t.string "guid"
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mailing_list_emails", force: :cascade do |t|
    t.bigint "mailing_list_id", null: false
    t.bigint "user_id"
    t.string "email"
    t.index ["mailing_list_id"], name: "index_mailing_list_emails_on_mailing_list_id"
    t.index ["user_id"], name: "index_mailing_list_emails_on_user_id"
  end

  create_table "mailing_lists", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.index ["user_id"], name: "index_mailing_lists_on_user_id"
  end

  create_table "poll_responses", force: :cascade do |t|
    t.bigint "poll_id"
    t.bigint "respondent_id"
    t.string "choice"
    t.boolean "example_response", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "respondent_type"
    t.index ["poll_id"], name: "index_poll_responses_on_poll_id"
    t.index ["respondent_id"], name: "index_poll_responses_on_respondent_id"
  end

  create_table "polls", force: :cascade do |t|
    t.string "question"
    t.bigint "event_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["event_id"], name: "index_polls_on_event_id"
    t.index ["user_id"], name: "index_polls_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.string "role", default: "user"
    t.string "slug"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.string "votable_type"
    t.integer "votable_id"
    t.string "voter_type"
    t.integer "voter_id"
    t.boolean "vote_flag"
    t.string "vote_scope"
    t.integer "vote_weight"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendances", "attendances"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "events", "addresses"
  add_foreign_key "events", "users"
end
