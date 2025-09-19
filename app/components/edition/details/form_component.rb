class Edition
  module Details
    class FormComponent < ViewComponent::Base
      def initialize(edition:, schema:)
        @edition = edition
        @schema = schema
      end

    private

      attr_reader :edition, :schema

      def component_for_field(field)
        component_name = field.component_name
        component_class = "Edition::Details::Fields::#{component_name.camelize}Component".constantize
        args = component_args(field).merge(enum: field.enum_values, default: field.default_value)

        component_class.new(**args.compact)
      end

      def component_args(field)
        {
          edition:,
          field:,
          value: edition.details&.fetch(field.name, nil),
          schema:,
        }
      end

      def fields
        schema.fields
      end
    end
  end
end
