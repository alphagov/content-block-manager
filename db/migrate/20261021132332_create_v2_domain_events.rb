class CreateV2DomainEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :v2_domain_events do |t|
      t.integer :user_id
      t.integer :v2_edition_id
      t.integer :v2_document_id
      t.string :name, null: false
      t.jsonb :metadata
      t.integer :v2_version_id

      t.timestamps
    end
    add_index :v2_domain_events, :user_id
    add_index :v2_domain_events, :v2_edition_id
    add_index :v2_domain_events, :v2_document_id
    add_index :v2_domain_events, :name
    add_index :v2_domain_events, :v2_version_id
  end
end
