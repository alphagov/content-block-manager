class DropOrganisationsTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :organisations do |t|
      t.text :name, null: false
      t.text :slug, null: false
      t.text :url
      t.text :govuk_status, null: false, default: "live"
      t.datetime :closed_at
      t.text :content_id
      t.boolean :political, null: false, default: false
      t.text :organisation_type_key, null: false
      t.text :govuk_closed_status

      t.timestamps
    end

    drop_table :content_block_edition_organisations do |t|
      t.integer :content_block_edition_id, null: false
      t.integer :organisation_id, null: false

      t.timestamps
    end
  end
end
