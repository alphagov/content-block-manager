class RenameBlockTablesToV2 < ActiveRecord::Migration[8.1]
  def change
    rename_table :block_documents, :v2_documents
    rename_table :block_editions, :v2_editions
    rename_column :v2_editions, :block_document_id, :v2_document_id
    rename_table :block_time_period_date_ranges, :v2_time_period_date_ranges
  end
end
