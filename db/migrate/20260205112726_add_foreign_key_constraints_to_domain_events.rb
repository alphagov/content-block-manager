class AddForeignKeyConstraintsToDomainEvents < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :domain_events, :users
    add_foreign_key :domain_events, :editions
    add_foreign_key :domain_events, :documents
    add_foreign_key :domain_events, :versions
  end
end
