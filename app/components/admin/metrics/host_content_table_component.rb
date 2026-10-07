class Admin::Metrics::HostContentTableComponent < ViewComponent::Base
  include AbbreviatedNumberHelper

  PLACEHOLDER = "–".freeze

  def initialize(documents:)
    @documents = documents
  end

private

  attr_reader :documents

  def head
    ["Organisation", "Block", "Block type", "Embed code", "Locations", "Instances", "Views (30 days)", "Orgs"]
      .map { |heading| { text: heading } }
  end

  def rows
    documents.map { |document| row_for(document) }
  end

  def row_for(document)
    rollup_metric = document.rollup_metric

    [
      { text: rollup_metric&.lead_organisation_name || PLACEHOLDER },
      { text: link_to(document.title, helpers.document_path(document), class: "govuk-link") },
      { text: document.block_type.humanize },
      { text: document.built_embed_code },
      { text: formatted_metric(rollup_metric&.locations) },
      { text: formatted_metric(rollup_metric&.instances) },
      { text: formatted_metric(rollup_metric&.views) },
      { text: formatted_metric(rollup_metric&.organisations) },
    ]
  end

  def formatted_metric(value)
    value.nil? ? PLACEHOLDER : abbreviated_number(value)
  end
end
