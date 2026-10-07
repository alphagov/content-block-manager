class Admin::Metrics::HostContentTableComponent < ViewComponent::Base
  include AbbreviatedNumberHelper

  PLACEHOLDER = "–".freeze

  COLUMNS = [
    { heading: "Organisation", sort_by: "lead_organisation_name" },
    { heading: "Block" },
    { heading: "Block type", sort_by: "block_type" },
    { heading: "Embed code" },
    { heading: "Locations", sort_by: "locations" },
    { heading: "Instances", sort_by: "instances" },
    { heading: "Views (30 days)", sort_by: "views" },
    { heading: "Orgs", sort_by: "organisations" },
  ].freeze

  def initialize(documents:, order:)
    @documents = documents
    @order = order
  end

private

  attr_reader :documents, :order

  def head
    COLUMNS.map do |column|
      next { text: column[:heading] } unless column[:sort_by]

      {
        text: column[:heading],
        href: sort_link(column[:sort_by]),
        sort_direction: sort_direction(column[:sort_by]),
      }
    end
  end

  def sort_direction(column)
    case order
    when column then "ascending"
    when "-#{column}" then "descending"
    end
  end

  def sort_link(column)
    column = "-#{column}" if sort_direction(column) == "ascending"
    helpers.admin_metrics_host_content_path(order: column)
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
