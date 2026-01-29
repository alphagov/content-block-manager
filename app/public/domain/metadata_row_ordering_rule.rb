class MetadataRowOrderingRule
  def initialize(field_order:)
    @field_order = field_order
  end

  attr_reader :field_order

  def call(row)
    field = row.fetch(:field).is_a?(String) ? row.fetch(:field).downcase : row.fetch(:field)

    if field_order
      # If a field order is found in the config, order by the index. If a field is not found, put it to the end
      field_order.index(field) || Float::INFINITY
    else
      # By default, order with title first
      field == "title" ? 0 : 1
    end
  end
end
