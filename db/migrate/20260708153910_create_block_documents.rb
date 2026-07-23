class CreateBlockDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :block_documents do |t|
      t.uuid :content_id
      t.string :sluggable_string
      t.string :content_id_alias
      t.string :block_type
      t.datetime :deleted_at
      t.string :embed_code
      t.boolean :testing_artefact

      t.timestamps
    end
  end
end
