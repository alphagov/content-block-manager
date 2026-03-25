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

ActiveRecord::Schema[8.1].define(version: 2026_03_25_180000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "block_documents", force: :cascade do |t|
    t.string "block_type", null: false
    t.uuid "content_id", null: false
    t.string "content_id_alias"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "embed_code"
    t.string "sluggable_string", null: false
    t.boolean "testing_artefact", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_block_documents_on_content_id", unique: true
    t.index ["content_id_alias"], name: "index_block_documents_on_content_id_alias", unique: true
    t.index ["sluggable_string"], name: "index_block_documents_on_sluggable_string", unique: true
  end

  create_table "block_editions", force: :cascade do |t|
    t.bigint "block_document_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.text "instructions_to_publishers"
    t.uuid "lead_organisation_id"
    t.string "title", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["block_document_id"], name: "index_block_editions_on_block_document_id"
    t.index ["type"], name: "index_block_editions_on_type"
  end

  create_table "block_time_period_date_ranges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "edition_id", null: false
    t.datetime "end", null: false
    t.datetime "start", null: false
    t.datetime "updated_at", null: false
    t.index ["edition_id"], name: "index_block_time_period_date_ranges_on_edition_id"
  end

  create_table "documents", force: :cascade do |t|
    t.text "block_type"
    t.text "content_id"
    t.string "content_id_alias"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.text "embed_code"
    t.text "sluggable_string"
    t.boolean "testing_artefact", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["content_id_alias"], name: "index_documents_on_content_id_alias", unique: true
    t.index ["embed_code"], name: "index_documents_on_embed_code", unique: true
  end

  create_table "domain_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "document_id"
    t.integer "edition_id"
    t.jsonb "metadata"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "version_id"
    t.index ["document_id"], name: "index_domain_events_on_document_id"
    t.index ["edition_id"], name: "index_domain_events_on_edition_id"
    t.index ["name"], name: "index_domain_events_on_name"
    t.index ["user_id"], name: "index_domain_events_on_user_id"
    t.index ["version_id"], name: "index_domain_events_on_version_id"
  end

  create_table "edition_authors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "edition_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["edition_id"], name: "index_edition_authors_on_edition_id"
    t.index ["user_id"], name: "index_edition_authors_on_user_id"
  end

  create_table "editions", force: :cascade do |t|
    t.string "auth_bypass_id"
    t.text "change_note"
    t.datetime "created_at", null: false
    t.json "details", null: false
    t.integer "document_id", null: false
    t.text "instructions_to_publishers"
    t.text "internal_change_note"
    t.uuid "lead_organisation_id"
    t.boolean "major_change"
    t.datetime "scheduled_publication"
    t.text "state", default: "draft", null: false
    t.text "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.datetime "workflow_completed_at", precision: nil
    t.index ["document_id"], name: "index_editions_on_document_id"
    t.index ["title"], name: "index_editions_on_title"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "document_id"
    t.integer "edition_id"
    t.jsonb "metadata"
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "version_id"
    t.index ["document_id"], name: "index_events_on_document_id"
    t.index ["edition_id"], name: "index_events_on_edition_id"
    t.index ["name"], name: "index_events_on_name"
    t.index ["user_id"], name: "index_events_on_user_id"
    t.index ["version_id"], name: "index_events_on_version_id"
  end

  create_table "flipflop_features", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false, null: false
    t.text "key", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipflop_features_on_key"
  end

  create_table "outcomes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.bigint "domain_event_id"
    t.bigint "edition_id", null: false
    t.string "performer"
    t.boolean "skipped"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_outcomes_on_creator_id"
    t.index ["domain_event_id"], name: "index_outcomes_on_domain_event_id"
    t.index ["edition_id"], name: "index_outcomes_on_edition_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "disabled", default: false
    t.text "email"
    t.text "name", null: false
    t.string "organisation_content_id"
    t.string "organisation_slug"
    t.text "permissions"
    t.boolean "remotely_signed_out", default: false
    t.text "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["uid"], name: "index_users_on_uid"
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event", null: false
    t.json "field_diffs"
    t.integer "item_id", null: false
    t.text "item_type", null: false
    t.text "state"
    t.datetime "updated_at", null: false
    t.text "whodunnit"
    t.index ["item_id"], name: "index_versions_on_item_id"
    t.index ["item_type"], name: "index_versions_on_item_type"
  end

  add_foreign_key "block_editions", "block_documents"
  add_foreign_key "block_time_period_date_ranges", "block_editions", column: "edition_id"
  add_foreign_key "domain_events", "documents"
  add_foreign_key "domain_events", "editions"
  add_foreign_key "domain_events", "users"
  add_foreign_key "domain_events", "versions"
  add_foreign_key "outcomes", "domain_events"
  add_foreign_key "outcomes", "editions"
  add_foreign_key "outcomes", "users", column: "creator_id"
end
