class CreateV2PensionAmounts < ActiveRecord::Migration[8.1]
  def change
    create_table :v2_pension_amounts do |t|
      t.references :edition, null: false, foreign_key: { to_table: :v2_editions }
      t.decimal :amount, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
