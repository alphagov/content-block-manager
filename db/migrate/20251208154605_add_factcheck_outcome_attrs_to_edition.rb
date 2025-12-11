class AddFactcheckOutcomeAttrsToEdition < ActiveRecord::Migration[8.0]
  def change
    change_table(:editions, bulk: true) do |t|
      t.column :factcheck_skipped, :boolean
      t.column :factcheck_outcome_recorded_by, :integer
      t.column :factcheck_outcome_recorded_at, :datetime
      t.column :factcheck_outcome_reviewer, :string
    end
  end
end
