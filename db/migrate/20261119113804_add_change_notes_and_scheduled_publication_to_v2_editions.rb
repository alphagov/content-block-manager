class AddChangeNotesAndScheduledPublicationToV2Editions < ActiveRecord::Migration[8.1]
  def change
    change_table :v2_editions, bulk: true do |t|
      t.string :internal_change_note
      t.string :change_note
      t.datetime :scheduled_for_publication_at
    end
  end
end
