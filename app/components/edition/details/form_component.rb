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

      def context(field)
        Edition::Details::Fields::Context.new(
          edition:,
          field:,
          schema:,
          populate_with_defaults:,
        )
      end

      def fields
        schema.fields
      end
    end
  end
end
