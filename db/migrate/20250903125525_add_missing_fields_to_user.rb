class AddMissingFieldsToUser < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :organisation_slug
      t.string :organisation_content_id
    end
  end
end
