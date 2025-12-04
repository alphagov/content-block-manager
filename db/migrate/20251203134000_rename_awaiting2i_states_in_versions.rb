class RenameAwaiting2iStatesInVersions < ActiveRecord::Migration[8.0]
  def change
    Version.where(state: "awaiting_2i")
           .update_all(state: "awaiting_review")
  end
end
