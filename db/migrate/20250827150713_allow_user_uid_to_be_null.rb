class AllowUserUidToBeNull < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :uid, true
  end
end
