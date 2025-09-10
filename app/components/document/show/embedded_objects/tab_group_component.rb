class Document::Show::EmbeddedObjects::TabGroupComponent < ViewComponent::Base
  def initialize(document:, subschemas:)
    @edition = document.latest_edition
    @subschemas = subschemas
  end

private

  attr_reader :edition, :subschemas

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
      subschema:,
    )
  end
end
