class Outcome < ApplicationRecord
  EVENT_SCOPE_BY_TYPE = {
    "ReviewOutcome" => "review",
    "FactCheckOutcome" => "fact_check",
  }.freeze

  validates :type, presence: true
  belongs_to :edition
  belongs_to :creator, class_name: "User"
  belongs_to :domain_event, optional: true

  before_create :create_domain_event

  def result
    skipped ? "skipped" : "performed"
  end

  def event_scope
    EVENT_SCOPE_BY_TYPE.fetch(type)
  end

private

  def create_domain_event
    metadata = result == "performed" ? { performer: } : {}
    self.domain_event = DomainEvent.record(
      document: edition.document,
      user: creator,
      name: event_name,
      edition: edition,
      version: nil,
      metadata:,
    )
  end

  def event_name
    "edition.#{event_scope}.#{result}"
  end
end
