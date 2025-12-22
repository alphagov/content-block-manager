FactoryBot.define do
  factory :field, class: "Schema::Field" do
    name { "name" }
    schema { build(:schema) }

    transient do
      is_required? { true }
      default_value { nil }
      array_items { nil }
      format { "text" }
      enum_values { nil }
      govspeak_enabled? { false }
      nested_fields { nil }
      component_name { "string" }
      component_for_field { Edition::Details::Fields::StringComponent }
      data_attributes { nil }
      hidden? { false }
      show_field { nil }
      label { nil }
      title { nil }
      hint { nil }
    end

    initialize_with do
      new(name, schema)
    end

    after(:build) do |field, evaluator|
      allow(field).to receive(:is_required?).and_return(evaluator.is_required?)
      allow(field).to receive(:default_value).and_return(evaluator.default_value)
      allow(field).to receive(:array_items).and_return(evaluator.array_items)
      allow(field).to receive(:format).and_return(evaluator.format)
      allow(field).to receive(:enum_values).and_return(evaluator.enum_values)
      allow(field).to receive(:govspeak_enabled?).and_return(evaluator.govspeak_enabled?)
      allow(field).to receive(:nested_fields).and_return(evaluator.nested_fields)
      allow(field).to receive(:component_name).and_return(evaluator.component_name)
      allow(field).to receive(:data_attributes).and_return(evaluator.data_attributes)
      allow(field).to receive(:hidden?).and_return(evaluator.hidden?)
      allow(field).to receive(:component_class).and_return(evaluator.component_class)
      allow(field).to receive(:show_field).and_return(evaluator.show_field)
      allow(field).to receive(:label).and_return(evaluator.label)
      allow(field).to receive(:title).and_return(evaluator.title)
      allow(field).to receive(:hint).and_return(evaluator.hint)
    end
  end
end
