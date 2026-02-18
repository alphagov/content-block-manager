class FactCheck::TabGroupDiffComponent < ViewComponent::Base
  def initialize(block:, subschemas:)
    @block = block
    @subschemas = subschemas
    @combined_details = CombinedEditionDetails.new(published_details: block.published_block&.details, new_details: block.details)
  end

private

  attr_reader :block, :subschemas

  def tabs
    subschemas.sort_by(&:group_order).map do |subschema|
      tab_for_subschema(subschema)
    end
  end

  def tab_for_subschema(subschema)
    combined_block_content = BlockContent.new(
      OpenStruct.new(document: block.document, details: @combined_details.content),
      subschema,
    )
    embedded_object_titles = @combined_details.content.fetch(subschema.id, {}).keys
    component = FactCheck::SubschemaGroupDiffComponent.new(block:, subschema:, combined_block_content:, embedded_object_titles:)

    {
      id: component.id,
      label: component.label,
      content: render(component),
    }
  end
end
