class Admin::Metrics::HostContentTableComponent < ViewComponent::Base
  include AbbreviatedNumberHelper

  PLACEHOLDER = "–".freeze

  Column = Data.define(:heading, :sort_by, :value) do
    def initialize(heading:, value:, sort_by: nil)
      super
    end
  end

  def initialize(documents:, order:)
    @documents = documents
    @order = order
  end

private

  attr_reader :documents, :order

  def columns
    @columns ||= [
      Column.new(
        heading: "Organisation",
        sort_by: "lead_organisation_name",
        value: ->(document) { document.rollup_metric&.lead_organisation_name || PLACEHOLDER },
      ),
      Column.new(
        heading: "Block",
        value: ->(document) { link_to(document.title, helpers.document_path(document), class: "govuk-link") },
      ),
      Column.new(
        heading: "Block type",
        sort_by: "block_type",
        value: ->(document) { document.block_type.humanize },
      ),
      Column.new(
        heading: "Embed code / Content ID",
        value: value_for_embed_code_and_content_id,
      ),
      metric_column("Locations", :locations),
      metric_column("Instances", :instances),
      metric_column("Views (30 days)", :views),
      metric_column("Orgs", :organisations),
    ]
  end

  def metric_column(heading, metric)
    Column.new(
      heading:,
      sort_by: metric.to_s,
      value: ->(document) { formatted_metric(document.rollup_metric&.public_send(metric)) },
    )
  end

  def head
    columns.map do |column|
      next { text: column.heading } unless column.sort_by

      {
        text: column.heading,
        href: sort_link(column.sort_by),
        sort_direction: sort_direction(column.sort_by),
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
    columns.map { |column| { text: column.value.call(document) } }
  end

  def formatted_metric(value)
    value.nil? ? PLACEHOLDER : abbreviated_number(value)
  end

  def value_for_embed_code_and_content_id
    lambda { |document|
      [
        content_tag(:div, class: "embed-code") do
          content_tag(:code, document.built_embed_code)
        end,
        content_tag(:div, class: "content-id") do
          content_tag(:code, document.content_id)
        end,
      ].join.html_safe
    }
  end
end
