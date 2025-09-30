class Editions::OrderController < BaseController
  include Workflow::Steps

  def edit
    @order = params[:order] || @edition.details["order"] || default_order
  end

  def update
    @edition.details["order"] = params[:order]
    @edition.save!
  end

private

  def default_order
    @edition.schema.subschemas.map { |subschema|
      item_keys = @edition.details[subschema.block_type]&.keys || []
      item_keys.map do |item_key|
        "#{subschema.block_type}.#{item_key}"
      end
    }.flatten
  end
end
