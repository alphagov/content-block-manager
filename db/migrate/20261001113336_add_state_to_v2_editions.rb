class AddStateToV2Editions < ActiveRecord::Migration[8.1]
  def change
    add_column :v2_editions, :state, :string, default: "draft", null: false

    add_index :v2_editions, :state
  end
end
