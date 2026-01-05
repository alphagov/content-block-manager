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

      def component_args(field)
        {
          edition:,
          field:,
          value: helpers.value_for_field(details: edition.details, field:, populate_with_defaults:),
          schema:,
          populate_with_defaults:,
        }
      end

      def fields
        schema.fields
      end
    end
  end
end
