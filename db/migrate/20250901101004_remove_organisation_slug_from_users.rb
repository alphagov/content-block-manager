class RemoveOrganisationSlugFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :organisation_slug, :text
  end
end
