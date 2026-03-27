desc "Remove version_id from outcome domain events"
task remove_version_id_from_outcome_domain_events: :environment do
  domain_events = DomainEvent.where(name: ["edition.review.performed",
                                           "edition.review.skipped",
                                           "edition.fact_check.performed",
                                           "edition.fact_check.skipped"])

  domain_events.each do |de|
    # :nocov:
    if ENV["RAILS_ENV"] != "test"
      puts "Removing version_id #{de.version_id} from DomainEvent #{de.id}"
    end
    # :nocov:

    de.version_id = nil
    de.save!
  end
end
