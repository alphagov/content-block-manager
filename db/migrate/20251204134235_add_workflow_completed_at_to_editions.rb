class AddWorkflowCompletedAtToEditions < ActiveRecord::Migration[8.0]
  def change
    add_column :editions, :workflow_completed_at, :timestamp
  end
end
