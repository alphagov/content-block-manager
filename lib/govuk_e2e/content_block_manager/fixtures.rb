module GovukE2e
  module ContentBlockManager
    module Fixtures
      DOCUMENT_ID = 18
      DOCUMENT_CONTENT_ID = "640637ae-f9ce-448d-b7d5-180906511248".freeze
      CONTENT_ID_ALIAS = "test-content-block-do-not-use".freeze
      BLOCK_TYPE = "pension".freeze
      SLUGGABLE_STRING = "Test Content Block - Do Not Use".freeze
      TITLE = "Test Content Block - Do Not Use".freeze
      LEAD_ORGANISATION_ID = "af07d5a5-df63-4ddc-9383-6a666845ebe9".freeze

      DETAILS = {
        "rates" => {
          "rate-1" => {
            "title" => "Rate 1",
            "amount" => "134.64",
            "frequency" => "a week",
            "description" => "Some description goes here",
          },
        },
        "description" => "This is a test content block for end-to-end testing",
      }.freeze

      def self.seed!
        return if Document.where(id: DOCUMENT_ID).exists?

        test_user = test_user!
        document = create_document

        Edition::HasAuditTrail.acting_as(test_user) do
          Edition.create!(
            document:,
            state: "draft",
            title: TITLE,
            details: DETAILS,
            creator: test_user,
            lead_organisation_id: LEAD_ORGANISATION_ID,
            instructions_to_publishers: "This is a test content block for end-to-end testing",
            change_note: "",
            major_change: false,
          )
        end
      end

      def self.create_document
        Document.create!(
          id: DOCUMENT_ID,
          content_id: DOCUMENT_CONTENT_ID,
          sluggable_string: SLUGGABLE_STRING,
          block_type: BLOCK_TYPE,
          content_id_alias: CONTENT_ID_ALIAS,
          embed_code: "{{embed:content_block_#{BLOCK_TYPE}:#{CONTENT_ID_ALIAS}}}",
        )
      end

      def self.test_user!
        User.find_by(name: "Test user") ||
          raise(<<~MESSAGE)
            Expected the "Test user" from db/seeds.rb to exist. Run `rake db:seed`
            before seeding the GOV.UK end-to-end fixtures.
          MESSAGE
      end
    end
  end
end
