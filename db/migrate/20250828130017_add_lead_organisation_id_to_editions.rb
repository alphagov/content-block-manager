class AddLeadOrganisationIdToEditions < ActiveRecord::Migration[8.0]
  def change
    add_column :content_block_editions, :lead_organisation_id, :uuid
  end
end
