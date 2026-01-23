class RemoveEmbeddedObjectFieldsFromVersions < ActiveRecord::Migration[8.0]
  def change
    change_table :versions, bulk: true do |t|
      t.remove :updated_embedded_object_type, type: :text
      t.remove :updated_embedded_object_title, type: :text
    end
  end
end
