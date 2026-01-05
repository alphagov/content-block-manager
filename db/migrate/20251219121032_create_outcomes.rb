class CreateOutcomes < ActiveRecord::Migration[8.0]
  def change
    create_table :outcomes do |t|
      t.references :edition, null: false, foreign_key: true
      t.string :type
      t.boolean :skipped
      t.string :performer_identifier

      t.references :performer, foreign_key: { to_table: :users }
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
