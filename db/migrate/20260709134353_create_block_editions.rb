class CreateBlockEditions < ActiveRecord::Migration[8.1]
  def change
    create_table :block_editions do |t|
      t.references :block_document, null: false, foreign_key: true
      t.string :type
      t.string :title
      t.text :description
      t.text :instructions_to_publishers
      t.uuid :lead_organisation_id

      t.timestamps
    end
  end
end
