class Document::Show::EmbeddedObjects::TabGroupComponent < ViewComponent::Base
  def initialize(edition:, schema:, subschemas:)
    @edition = edition
    @schema = schema
    @subschemas = subschemas
  end

private

  attr_reader :edition, :schema, :subschemas

  def tabs
    subschemas.sort_by(&:group_order).map do |subschema|
      tab_for_subschema(subschema)
    end
  end

  def tab_for_subschema(subschema)
    component = component_for_subschema(subschema)
    {
      id: component.id,
      label: component.label,
      content: render(component),
    }
  end

  def component_for_subschema(subschema)
    Document::Show::EmbeddedObjects::SubschemaItemsComponent.new(
      edition:,
      schema:,
      subschema:,
    )
  end
end
