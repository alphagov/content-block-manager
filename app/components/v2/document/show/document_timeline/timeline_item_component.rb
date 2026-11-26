require "record_tag_helper/helper"

class V2::Document::Show::DocumentTimeline::TimelineItemComponent < ViewComponent::Base
  include ActionView::Helpers::RecordTagHelper

  def initialize(domain_event:, is_first_published_version:, is_latest:)
    @domain_event = domain_event
    @is_first_published_version = is_first_published_version
    @is_latest = is_latest
  end

private

  attr_reader :domain_event, :is_first_published_version, :is_latest

  def version
    domain_event.version
  end

  def edition
    domain_event.edition
  end

  def title
    return I18n.t("domain_event.title.#{domain_event.name}") unless version

    case version.state
    when "published"
      if is_first_published_version
        I18n.t("timeline_item.title.published", block_type: version.item.document.block_type.humanize)
      else
        version.state.capitalize
      end
    when "scheduled"
      I18n.t("timeline_item.title.scheduled", datetime_string:)
    when "draft_complete"
      I18n.t("timeline_item.title.draft_complete")
    else
      "#{version.item.document.block_type.humanize} #{version.state}"
    end
  end

  def datetime_string
    # we need a bit of logic here to handle historic Version/Domain Event pairs created before the update to DomainEvent metadata population
    if domain_event.metadata.key?("scheduled_for_publication_at")
      "on #{Time.zone.parse(domain_event.metadata['scheduled_for_publication_at']).to_fs(:long_ordinal_with_at)}"
    elsif version.item.scheduled_for_publication_at
      "on #{version.item.scheduled_for_publication_at.to_fs(:long_ordinal_with_at)}"
    else
      # Backup to prevent exception for Version/DomainEvent pairs which would have been affected by the bug caused by manual publishing
      ""
    end
  end

  def date
    tag.time(
      domain_event.created_at.to_fs(:long_ordinal_with_at),
      class: "date",
      datetime: domain_event.created_at.iso8601,
      lang: "en",
    )
  end

  def byline
    User.find_by_id(domain_event.user_id)&.then { |user| helpers.linked_author(user, { class: "govuk-link" }) } || "unknown user"
  end

  def internal_change_note
    edition.internal_change_note
  end

  def change_note
    edition.change_note
  end

  def details_of_changes
    @details_of_changes ||= begin
      return "" if version&.field_diffs.blank?

      field_changes
    end
  end

  def field_changes
    render V2::Document::Show::DocumentTimeline::FieldChangesTableComponent.new(version:)
  end
end
