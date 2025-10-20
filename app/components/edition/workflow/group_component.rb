class Edition::Workflow::GroupComponent < ViewComponent::Base
  def initialize(edition:, subschemas:)
    @edition = edition
    @subschemas = subschemas
  end

private

  attr_reader :edition, :subschemas

  def tabs
    subschemas.sort_by(&:group_order).map { |subschema|
      tab_for_subschema(subschema)
    }.compact
  end

  def tab_for_subschema(subschema)
    items = items_for_subschema(subschema)
    if items.any?
      {
        id: subschema.id,
        label: tab_label(subschema, items),
        content: content_for_tab(subschema, items),
      }
    end
  end

  def tab_label(subschema, items)
    "#{subschema.name.singularize.capitalize} (#{items.values.count})"
  end

  def content_for_tab(subschema, items)
    render Shared::EmbeddedObjects::SummaryCardComponent.with_collection(
      items.keys,
      edition: edition,
      object_type: subschema.block_type,
      redirect_url: request.fullpath,
    )
  end

  def items_for_subschema(subschema)
    edition.details.fetch(subschema.block_type, {})
  end
end
