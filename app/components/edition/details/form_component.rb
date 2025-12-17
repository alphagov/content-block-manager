class Edition
  module Details
    class FormComponent < ViewComponent::Base
      def initialize(edition:, schema:, populate_with_defaults:)
        @edition = edition
        @schema = schema
        @populate_with_defaults = populate_with_defaults
      end

    private

      attr_reader :edition, :schema, :populate_with_defaults

      def component_for_field(field)
        component_name = field.component_name
        component_class = "Edition::Details::Fields::#{component_name.camelize}Component".constantize
        args = component_args(field)

        component_class.new(**args.compact)
      end

      def component_args(field)
        {
          edition:,
          field:,
          value: helpers.value_for_field(details: edition.details, field:, populate_with_defaults:),
          schema:,
        }
      end

      def fields
        schema.fields
      end
    end
  end
end
