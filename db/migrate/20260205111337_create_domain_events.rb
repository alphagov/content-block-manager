class CreateDomainEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :domain_events do |t|
      t.integer :user_id
      t.integer :edition_id
      t.integer :document_id
      t.string :name, null: false
      t.jsonb :metadata
      t.integer :version_id

      t.timestamps
    end
    add_index :domain_events, :user_id
    add_index :domain_events, :edition_id
    add_index :domain_events, :document_id
    add_index :domain_events, :name
    add_index :domain_events, :version_id
  end
end
