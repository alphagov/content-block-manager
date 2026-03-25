class ChangeLeadOrganisationIdToUuidInBlockEditions < ActiveRecord::Migration[8.1]
  def up
    change_table :block_editions, bulk: true do |t|
      t.remove :lead_organisation_id, type: :integer
      t.uuid :lead_organisation_id
    end
  end

  def down
    change_table :block_editions, bulk: true do |t|
      t.remove :lead_organisation_id, type: :uuid
      t.integer :lead_organisation_id
    end
  end
end
