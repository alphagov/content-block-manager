class CreateRollupMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :rollup_metrics do |t|
      t.references :document, null: false, foreign_key: true, index: { unique: true }
      t.bigint :views, null: false, default: 0
      t.integer :locations, null: false, default: 0
      t.integer :instances, null: false, default: 0
      t.integer :organisations, null: false, default: 0
      t.string :lead_organisation_name
      t.datetime :refreshed_at, null: false

      t.timestamps
    end
  end
end
