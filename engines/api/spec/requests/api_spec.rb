require "swagger_helper"

RSpec.describe "API" do
  path "/blocks/search" do
    get "Search content blocks" do
      tags "Content Blocks"
      produces "application/json"

      response "200", "blocks found" do
        before do
          organisation = build(:organisation)
          create(:edition, :published, document: create(:document))
          allow_any_instance_of(Edition).to receive(:lead_organisation).and_return(organisation)
        end

        schema type: :array, items: {
          type: :object,
          additionalProperties: false,
          properties: {
            title: { type: :string },
            block_type: { type: :string },
            organisation: {
              type: :object,
              properties: {
                name: { type: :string },
                content_id: { type: :string },
              },
            },
            state: { type: :string, enum: %w[published] },
            embed_code: { type: :string },
            formats: { type: :array, items: { type: :string } },
          },
        }
        run_test!
      end
    end
  end
end
