class BackfillOutcomeDomainEvents
  def self.call
    Outcome.where(domain_event: nil).find_each do |outcome|
      outcome.send(:create_domain_event)
      outcome.save!
    end
  end
end
