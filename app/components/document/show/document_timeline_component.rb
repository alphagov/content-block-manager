require "record_tag_helper/helper"

class Document::Show::DocumentTimelineComponent < ViewComponent::Base
  include ActionView::Helpers::RecordTagHelper
  def initialize(document_domain_events:, schema:)
    @document_domain_events = document_domain_events || []
    @schema = schema
  end

private

  attr_reader :document_domain_events, :schema

  def versions
    domain_events.map(&:version).compact
  end

  def domain_events
    document_domain_events.reject { |domain_event| hide_from_user?(domain_event) }
  end

  def hide_from_user?(domain_event)
    domain_event.version.present? && (domain_event.version.state.nil? || domain_event.version.state == "superseded")
  end

  def first_published_version
    @first_published_version ||= versions.filter { |v| v.state == "published" }.min_by(&:created_at)
  end
end
