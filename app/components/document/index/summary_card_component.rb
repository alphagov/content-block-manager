class Document::Index::SummaryCardComponent < ViewComponent::Base
  include EditionHelper

  def initialize(document:)
    @document = document
  end

private

  attr_reader :document

  def rows
    [
      title_item,
      *details_items,
      organisation_item,
      status_item,
    ].compact
  end

  def title_item
    {
      key: helpers.label_for_title(document.block_type),
      value: document.title,
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

  def schema
    @schema ||= edition.schema
  end

  def organisation_item
    {
      key: "Lead organisation",
      value: edition.lead_organisation.name,
    }
  end

  def status_item
    value = current_state_label(edition)
    if edition.state == "scheduled"
      {
        key: "Status",
        value: value,
        edit: {
          href: helpers.document_schedule_edit_path(document),
          link_text: sanitize("Edit <span class='govuk-visually-hidden'>schedule</span>"),
          link_text_no_enhance: true,
        },
      }
    else
      {
        key: "Status",
        value: value,
      }
    end
  end

  def title
    document.title
  end

  def summary_card_actions
    [
      {
        label: "View",
        href: helpers.document_path(document),
      },
    ]
  end

  def edition
    @edition = document.latest_published_edition
  end
end
