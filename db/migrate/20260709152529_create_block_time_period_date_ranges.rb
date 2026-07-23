class CreateBlockTimePeriodDateRanges < ActiveRecord::Migration[8.1]
  def change
    create_table :block_time_period_date_ranges do |t|
      t.references :edition, null: false, foreign_key: { to_table: :block_editions }
      t.datetime :start
      t.datetime :end

      t.timestamps
    end
  end
end
