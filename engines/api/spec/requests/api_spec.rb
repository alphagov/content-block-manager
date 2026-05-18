require "swagger_helper"

RSpec.describe "API" do
  path "/blocks/search" do
    before do
      organisation = build(:organisation)
      allow_any_instance_of(Edition).to receive(:lead_organisation).and_return(organisation)
    end

    get "Search for content blocks" do
      description <<~DESC
        This endpoint allows you to search for content blocks. You can filter by block type, lead organisation, and
        keyword, and the results are paginated.
      DESC

      tags "Content Blocks"
      produces "application/json"
      parameter name: "block_type", in: :query, type: :string
      let(:block_type) { nil }

      response "200", "blocks found" do
        before do
          create(:edition, :published, document: create(:document))
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

      response "200", "filters by block type", document: false do
        before do
          create(:edition, :published, document: create(:document, block_type: "pension"))
          create(:edition, :published, document: create(:document, block_type: "contact"))
        end

        let(:block_type) { "pension" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(1)
          expect(data.first["block_type"]).to eq("Pension")
        end
      end
    end
  end
end
