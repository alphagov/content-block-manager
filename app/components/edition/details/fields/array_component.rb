class Edition::Details::Fields::ArrayComponent < Edition::Details::Fields::BaseComponent
  def initialize(object_title: nil, **args)
    @object_title = object_title
    super(**args)
  end

private

  def label
    super.singularize
  end

  def value
    super || []
  end

  def items
    if value.count.positive?
      Array.new(value.count) do |index|
        {
          fields: render(component(index)),
          destroy_checkbox: destroy_checkbox(index),
        }
      end
    else
      [{ fields: render(component(0)) }]
    end
  end

  def empty
    render component(value.count.positive? ? value.count : 1)
  end

  def component(index)
    Edition::Details::Fields::Array::ItemComponent.new(
      field_name: label,
      array_items: field.array_items,
      name_prefix: name,
      id_prefix: id,
      value: value,
      index: index,
      errors:,
      error_lookup_prefix: "details_#{id_suffix}",
      can_be_deleted: can_be_deleted?(index),
      hints: hint_text,
    )
  end

  def destroy_checkbox(index)
    field_name = "#{name}[][_destroy]"
    if can_be_deleted?(index)
      render("govuk_publishing_components/components/checkboxes", { name: field_name, items: [{ label: "Delete", value: "1" }] })
    else
      hidden_field_tag(field_name, 0)
    end
  end

  def errors
    edition.errors
  end

  def can_be_deleted?(index)
    immutability_checker&.can_be_deleted?(index)
  end

  def immutability_checker
    @immutability_checker ||= EmbeddedObjectImmutabilityCheck.new(
      edition: edition.document.latest_published_edition,
      field_reference: [subschema_block_type, @object_title, field.name].compact,
    )
  end
end
