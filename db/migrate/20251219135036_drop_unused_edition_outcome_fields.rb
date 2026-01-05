class DropUnusedEditionOutcomeFields < ActiveRecord::Migration[8.0]
  def change
    change_table :editions, bulk: true do
      remove_column :editions, :review_skipped, :boolean
      remove_column :editions, :review_outcome_recorded_by, :integer
      remove_column :editions, :review_outcome_recorded_at, :datetime
      remove_column :editions, :factcheck_skipped, :boolean
      remove_column :editions, :factcheck_outcome_recorded_by, :integer
      remove_column :editions, :factcheck_outcome_recorded_at, :datetime
      remove_column :editions, :factcheck_outcome_reviewer, :string
    end
  end
end
