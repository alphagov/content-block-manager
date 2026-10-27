class CreateV2Versions < ActiveRecord::Migration[8.1]
  def change
    create_table :v2_versions do |t|
      t.text :item_type, null: false
      t.integer :item_id, null: false
      t.integer :event, null: false
      t.text :whodunnit
      t.text :state
      t.json :field_diffs
      t.text :updated_embedded_object_type
      t.text :updated_embedded_object_title

      t.timestamps
    end
    add_index :v2_versions, :item_type
    add_index :v2_versions, :item_id
  end
end
