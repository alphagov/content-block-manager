class Document::Show::SummaryListComponent < ViewComponent::Base
  include EditionHelper
  include EmbedCodeHelper

  def initialize(document:)
    @document = document
  end

private

  attr_reader :document

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
      field: "Title",
      value: document.title,
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
        data: data_attributes_for_row(key),
      }]
      rows.push(embed_code_row(key, document)) if should_show_embed_code?(key)
      rows
    }.flatten
  end

  def data_attributes_for_row(key)
    copy_embed_code_data_attributes(key, document) if should_show_embed_code?(key)
  end

  def should_show_embed_code?(key)
    embeddable_fields.include?(key)
  end

  def schema
    @schema ||= document.schema
  end

  def embeddable_fields
    @embeddable_fields = schema.embeddable_fields
  end

  def status_item
    if edition.state == "scheduled"
      {
        field: "Status",
        value: scheduled_value,
        edit: {
          href: helpers.document_schedule_edit_path(document),
          link_text: sanitize("Edit <span class='govuk-visually-hidden'>schedule</span>"),
        },
      }
    else
      {
        field: "Status",
        value: last_updated_value,
      }
    end
  end

  def last_updated_value
    "Published on #{published_date(edition)} by #{edition.creator.name}".html_safe
  end

  def scheduled_value
    "Scheduled for publication at #{scheduled_date(edition)}".html_safe
  end

  def edition
    @edition = document.latest_edition
  end
end
