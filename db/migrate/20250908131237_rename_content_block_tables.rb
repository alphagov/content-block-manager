class RenameContentBlockTables < ActiveRecord::Migration[8.0]
  def change
    rename_table :content_block_documents, :documents
    rename_table :content_block_editions, :editions
    rename_table :content_block_edition_authors, :edition_authors
    rename_table :content_block_versions, :versions
  end
end
