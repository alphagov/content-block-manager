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

ActiveRecord::Schema[8.0].define(version: 2025_12_19_135036) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "documents", force: :cascade do |t|
    t.text "content_id"
    t.text "sluggable_string"
    t.text "block_type"
    t.string "content_id_alias"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "testing_artefact", default: false, null: false
    t.text "embed_code"
    t.index ["content_id_alias"], name: "index_documents_on_content_id_alias", unique: true
    t.index ["embed_code"], name: "index_documents_on_embed_code", unique: true
  end

  create_table "edition_authors", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "edition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["edition_id"], name: "index_edition_authors_on_edition_id"
    t.index ["user_id"], name: "index_edition_authors_on_user_id"
  end

  create_table "editions", force: :cascade do |t|
    t.json "details", null: false
    t.integer "document_id", null: false
    t.text "state", default: "draft", null: false
    t.datetime "scheduled_publication"
    t.text "instructions_to_publishers"
    t.text "title", default: "", null: false
    t.text "internal_change_note"
    t.text "change_note"
    t.boolean "major_change"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "lead_organisation_id"
    t.string "auth_bypass_id"
    t.boolean "review_skipped"
    t.integer "review_outcome_recorded_by"
    t.datetime "review_outcome_recorded_at"
    t.datetime "workflow_completed_at", precision: nil
    t.boolean "factcheck_skipped"
    t.integer "factcheck_outcome_recorded_by"
    t.datetime "factcheck_outcome_recorded_at"
    t.string "factcheck_outcome_reviewer"
    t.index ["document_id"], name: "index_editions_on_document_id"
    t.index ["title"], name: "index_editions_on_title"
  end

  create_table "flipflop_features", force: :cascade do |t|
    t.text "key", null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipflop_features_on_key"
  end

  create_table "outcomes", force: :cascade do |t|
    t.bigint "edition_id", null: false
    t.string "type"
    t.boolean "skipped"
    t.string "performer_identifier"
    t.bigint "performer_id"
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_outcomes_on_creator_id"
    t.index ["edition_id"], name: "index_outcomes_on_edition_id"
    t.index ["performer_id"], name: "index_outcomes_on_performer_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "name", null: false
    t.text "uid"
    t.text "email"
    t.boolean "disabled", default: false
    t.boolean "remotely_signed_out", default: false
    t.text "permissions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["uid"], name: "index_users_on_uid"
  end

  create_table "versions", force: :cascade do |t|
    t.text "item_type", null: false
    t.integer "item_id", null: false
    t.integer "event", null: false
    t.text "whodunnit"
    t.text "state"
    t.json "field_diffs"
    t.text "updated_embedded_object_type"
    t.text "updated_embedded_object_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_versions_on_item_id"
    t.index ["item_type"], name: "index_versions_on_item_type"
  end

  add_foreign_key "outcomes", "editions"
  add_foreign_key "outcomes", "users", column: "creator_id"
  add_foreign_key "outcomes", "users", column: "performer_id"
end
