class CreateBlockDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :block_documents do |t|
      t.uuid :content_id, null: false
      t.string :sluggable_string, null: false
      t.string :content_id_alias
      t.string :block_type, null: false
      t.datetime :deleted_at
      t.string :embed_code
      t.boolean :testing_artefact, default: false, null: false

      t.timestamps
    end

    add_index :block_documents, :content_id, unique: true
    add_index :block_documents, :sluggable_string, unique: true
    add_index :block_documents, :content_id_alias, unique: true
  end
end
