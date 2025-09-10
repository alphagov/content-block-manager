class Edition::Details::Fields::ObjectComponent < Edition::Details::Fields::BaseComponent
private

  def name_for_field(field)
    "#{name}[#{field.name}]"
  end

  def id_for_field(field)
    "#{id}_#{field.name}"
  end

  def errors_for_field(field)
    errors_for(edition.errors, "details_#{id_suffix}_#{field.name}".to_sym)
  end

  def value_for_field(field)
    value&.fetch(field.name, nil) || field.default_value
  end
end
