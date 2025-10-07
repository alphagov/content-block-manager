class AddTestingArtefactFieldToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :testing_artefact, :boolean, default: false, null: false
  end
end
