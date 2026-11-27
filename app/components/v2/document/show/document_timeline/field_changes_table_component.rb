class V2::Document::Show::DocumentTimeline::FieldChangesTableComponent < ViewComponent::Base
  def initialize(version:)
    @version = version
  end

private

  attr_reader :version

  def rows
    rows = []
    rows.push(title_row) if version.field_diffs["title"]
    rows.push(*details_rows)
    rows.push(organisation_row) if version.field_diffs["lead_organisation"]
    rows.push(instructions_to_publishers_row) if version.field_diffs["instructions_to_publishers"]
    rows.compact
  end

  def title_row
    [
      { text: helpers.label_for_title(version.item.document.block_type) },
      { text: version.field_diffs["title"].previous_value },
      { text: version.field_diffs["title"].new_value },
    ]
  end

  def organisation_row
    [
      { text: "Lead organisation" },
      { text: version.field_diffs["lead_organisation"].previous_value },
      { text: version.field_diffs["lead_organisation"].new_value },
    ]
  end

  def details_rows
    details_diffs = version.field_diffs["details"] || {}

    details_diffs.flat_map do |field, field_diff|
      flatten_diff(field_diff, field.humanize).map do |label, diff|
        [{ text: label }, { text: diff.previous_value }, { text: diff.new_value }]
      end
    end
  end

  def flatten_diff(diff, label)
    return [[label, diff]] unless diff.is_a?(Hash)

    diff.flat_map do |key, nested|
      flatten_diff(nested, "#{label} #{key.humanize.downcase}")
    end
  end

  def instructions_to_publishers_row
    [
      { text: "Instructions to publishers" },
      { text: version.field_diffs["instructions_to_publishers"].previous_value },
      { text: version.field_diffs["instructions_to_publishers"].new_value },
    ]
  end
end
