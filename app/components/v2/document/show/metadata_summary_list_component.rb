class V2::Document::Show::MetadataSummaryListComponent < ViewComponent::Base
  include EditionHelper

  def initialize(edition:)
    @edition = edition
    @document = edition.document
  end

private

  attr_reader :document, :edition

  def items
    [
      title_item,
      description_item,
      organisation_item,
      instructions_item,
      status_item,
    ].compact
  end

  def title_item
    {
      field: "#{document.block_type.humanize} name",
      value: edition.title,
    }
  end

  def organisation_item
    {
      field: I18n.t("v2.document.show.metadata_labels.organisation"),
      value: edition.lead_organisation.name,
    }
  end

  def instructions_item
    {
      field: I18n.t("v2.document.show.metadata_labels.instructions_to_publishers"),
      value: formatted_instructions_to_publishers(edition),
    }
  end

  def description_item
    {
      field: I18n.t("v2.document.show.metadata_labels.description"),
      value: edition.description,
    }
  end

  def status_item
    {
      field: I18n.t("v2.document.show.metadata_labels.status"),
      value: current_state_label(edition),
    }
  end
end
