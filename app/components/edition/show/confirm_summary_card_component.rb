class Edition::Show::ConfirmSummaryCardComponent < ViewComponent::Base
  include EditionHelper

  def initialize(edition:)
    @edition = edition
  end

private

  attr_reader :edition

  def title
    "#{edition.document.block_type.humanize} details"
  end

  def rows
    [
      title_item,
      *details_items,
      organisation_item,
      instructions_item,
    ].compact
  end

  def title_item
    {
      key: helpers.label_for_title(edition.block_type),
      value: edition.title,
    }
  end

  def details_items
    schema.fields.map do |field|
      {
        key: field.name.humanize,
        value: edition.details[field.name],
      }
    end
  end

  def organisation_item
    {
      key: "Lead organisation",
      value: edition.lead_organisation.name,
    }
  end

  def instructions_item
    {
      key: "Instructions to publishers",
      value: formatted_instructions_to_publishers(edition),
    }
  end

  def summary_card_actions
    [
      {
        label: "Edit",
        href: helpers.workflow_path(id: edition.id, step: :edit_draft),
      },
    ]
  end

  def schema
    @schema ||= edition.document.schema
  end
end
