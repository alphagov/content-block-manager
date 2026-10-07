class Document::RollupMetricsQuery
  DEFAULT_ORDER = "-views".freeze
  PER_PAGE = 100

  SORTABLE_COLUMNS = {
    "lead_organisation_name" => RollupMetric.arel_table[:lead_organisation_name],
    "block_type" => Document.arel_table[:block_type],
    "locations" => RollupMetric.arel_table[:locations],
    "instances" => RollupMetric.arel_table[:instances],
    "views" => RollupMetric.arel_table[:views],
    "organisations" => RollupMetric.arel_table[:organisations],
  }.freeze

  attr_reader :order

  def initialize(order:, page: nil)
    @order = allowed?(order) ? order : DEFAULT_ORDER
    @page = page
  end

  def documents
    Document.left_joins(:rollup_metric)
            .preload(:rollup_metric, :most_recent_edition)
            .order(sort_order, Document.arel_table[:id].asc)
            .page(page)
            .per(PER_PAGE)
  end

private

  attr_reader :page

  def allowed?(order)
    SORTABLE_COLUMNS.key?(order.to_s.delete_prefix("-"))
  end

  def sort_order
    column = SORTABLE_COLUMNS.fetch(order.delete_prefix("-"))
    direction = order.start_with?("-") ? column.desc : column.asc
    direction.nulls_last
  end
end
