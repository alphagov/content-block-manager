desc "Backfill outcome domain events"
task backfill_outcome_domain_events: :environment do
  BackfillOutcomeDomainEvents.call
end
