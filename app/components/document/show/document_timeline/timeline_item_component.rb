require "record_tag_helper/helper"

class Document::Show::DocumentTimeline::TimelineItemComponent < ViewComponent::Base
  include ActionView::Helpers::RecordTagHelper

  def initialize(version:, schema:, is_first_published_version:, is_latest:)
    @version = version
    @schema = schema
    @is_first_published_version = is_first_published_version
    @is_latest = is_latest
  end

private

  attr_reader :version, :schema, :is_first_published_version, :is_latest

  def title
    case version.state
    when "published"
      if is_first_published_version
        I18n.t("timeline_item.title.published", block_type: version.item.block_type.humanize)
      else
        version.state.capitalize
      end
    when "scheduled"
      I18n.t("timeline_item.title.scheduled", datetime_string: version.item.scheduled_publication.to_fs(:long_ordinal_with_at))
    when "draft_complete"
      I18n.t("timeline_item.title.draft_complete")
    when "awaiting_review"
      I18n.t("timeline_item.title.awaiting_review")
    when "awaiting_factcheck"
      I18n.t("timeline_item.title.awaiting_factcheck")
    else
      "#{version.item.block_type.humanize} #{version.state}"
    end
  end

  def outcome
    case version.state
    when "awaiting_factcheck"
      version.item.review_outcome
    when "published"
      version.item.fact_check_outcome
    end
  end

  def outcome_resolution
    review_name = I18n.t("timeline_item.outcome.name.review")
    fact_check_name = I18n.t("timeline_item.outcome.name.fact_check")

    review_type = version.state == "awaiting_factcheck" ? review_name : fact_check_name
    skipped_or_performed = outcome.skipped ? "skipped" : "performed"
    performer = outcome.performer ? " by #{outcome.performer.try(:name) || outcome.performer}" : ""

    "#{review_type} #{skipped_or_performed}#{performer}"
  end

  def date
    tag.time(
      version.created_at.to_fs(:long_ordinal_with_at),
      class: "date",
      datetime: version.created_at.iso8601,
      lang: "en",
    )
  end

  def byline
    User.find_by_id(version.whodunnit)&.then { |user| helpers.linked_author(user, { class: "govuk-link" }) } || "unknown user"
  end

  def internal_change_note
    version.item.internal_change_note
  end

  def change_note
    version.item.change_note
  end

  def embedded_object_diffs
    schema.subschemas.map { |subschema|
      version.field_diffs.dig("details", subschema.id)&.map do |object_id, field_diff|
        { object_id:, field_diff:, subschema_id: subschema.id }
      end
    }.flatten.compact
  end

  def show_details_of_changes?
    details_of_changes.present?
  end

  def details_of_changes
    @details_of_changes ||= begin
      return "" if version.field_diffs.blank?

      [
        main_object_field_changes,
        embedded_object_field_changes,
      ].join.html_safe
    end
  end

  def main_object_field_changes
    render Document::Show::DocumentTimeline::FieldChangesTableComponent.new(
      version:,
      schema:,
    )
  end

  def embedded_object_field_changes
    if embedded_object_diffs.any?
      embedded_object_diffs.map do |item|
        render Document::Show::DocumentTimeline::EmbeddedObject::FieldChangesTableComponent.new(
          **item,
          edition: version.item,
        )
      end
    end
  end
end
