class Editions::OrderController < BaseController
  include Workflow::Steps

  def edit
    subschemas = @edition.document.schema.subschemas.sort_by(&:group_order)
    @order = @edition.details["order"] || subschemas.map { |subschema|
      item_keys = @edition.details[subschema.block_type].keys
      item_keys.map do |item_key|
        "#{subschema.block_type}.#{item_key}"
      end
    }.flatten
  end

  def update
    @edition.details["order"] = params[:order]
    @edition.save!
  end
end
