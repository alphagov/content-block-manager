class RemoveUnusedFksFromDocuments < ActiveRecord::Migration[8.0]
  def change
    change_table(:documents, bulk: true) do |t|
      t.remove :live_edition_id, type: :integer
      t.remove :latest_edition_id, type: :integer
    end
  end
end
