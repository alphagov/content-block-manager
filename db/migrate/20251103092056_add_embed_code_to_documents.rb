class AddEmbedCodeToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :embed_code, :text
    add_index :documents, :embed_code, unique: true
  end
end
