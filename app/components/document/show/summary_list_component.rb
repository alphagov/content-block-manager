class Document::Show::SummaryListComponent < ViewComponent::Base
  include EditionHelper
  include EmbedCodeHelper

  def initialize(edition:)
    @edition = edition
    @document = edition.document
  end

private

  attr_reader :document, :edition

  def items
    [
      title_item,
      *details_items,
      organisation_item,
      instructions_item,
      status_item,
    ].compact
  end

  def title_item
    {
      field: I18n.t(
        "activerecord.attributes.edition/document.title.#{document.block_type}",
        default: I18n.t("activerecord.attributes.edition/document.title.default"),
      ),
      value: edition.title,
    }
  end

  def organisation_item
    {
      field: "Lead organisation",
      value: edition.lead_organisation.name,
    }
  end

  def instructions_item
    {
      field: "Instructions to publishers",
      value: formatted_instructions_to_publishers(edition),
    }
  end

  def details_items
    schema.fields.map { |field|
      key = field.name
      rows = [{
        field: key.humanize,
        value: edition.details[key],
      }]
      rows
    }.flatten
  end

  def schema
    @schema ||= document.schema
  end

  def block_display_fields
    @block_display_fields = schema.block_display_fields
  end

  def status_item
    value = current_state_label(edition)
    if edition.state == "scheduled"
      {
        field: "Status",
        value: value,
        edit: {
          href: helpers.document_schedule_edit_path(document),
          link_text: sanitize("Edit <span class='govuk-visually-hidden'>schedule</span>"),
        },
      }
    else
      {
        field: "Status",
        value: value,
      }
    end
  end
end
