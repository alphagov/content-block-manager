class UpdateVersionEditionItemTypes < ActiveRecord::Migration[8.0]
  def change
    Version.where(item_type: "ContentBlockManager::ContentBlock::Edition")
           .update_all(item_type: "Edition")
  end
end
