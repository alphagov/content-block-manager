class ReplaceOutcomePerformer < ActiveRecord::Migration[8.0]
  def change
    remove_reference :outcomes, :performer, foreign_key: { to_table: :users }

    rename_column :outcomes, :performer_identifier, :performer
  end
end
