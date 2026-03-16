class AddDomainEventIdToOutcome < ActiveRecord::Migration[8.1]
  def change
    add_reference :outcomes, :domain_event, null: true, foreign_key: true
  end
end
