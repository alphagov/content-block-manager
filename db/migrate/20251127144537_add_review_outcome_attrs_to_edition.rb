class AddReviewOutcomeAttrsToEdition < ActiveRecord::Migration[8.0]
  def change
    change_table(:editions, bulk: true) do |t|
      t.column :review_skipped, :boolean
      t.column :review_outcome_recorded_by, :integer
      t.column :review_outcome_recorded_at, :datetime
    end
  end
end
