require "swagger_helper"

RSpec.describe "API" do
  path "/blocks/search" do
    let(:organisations) do
      build_list(:organisation, 3)
    end

    before do
      allow(Organisation).to receive(:all).and_return(organisations)
    end

    get "Search for content blocks" do
      description <<~DESC
        This endpoint allows you to search for content blocks. You can filter by block type, lead organisation, and
        keyword, and the results are paginated.
      DESC

      tags "Content Blocks"
      produces "application/json"
      parameter name: "block_type", in: :query, type: :string
      parameter name: "lead_organisation_id", in: :query, type: :string

      let(:block_type) { nil }
      let(:lead_organisation_id) { nil }

      response "200", "blocks found" do
        before do
          create(:edition, :published, document: create(:document), lead_organisation_id: organisations.first.id)
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
          create(:edition, :published, document: create(:document, block_type: "pension"), lead_organisation_id: organisations.first.id)
          create(:edition, :published, document: create(:document, block_type: "contact"), lead_organisation_id: organisations.first.id)
        end

        let(:block_type) { "pension" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(1)
          expect(data.first["block_type"]).to eq("Pension")
        end
      end

      response "200", "filters by organisation", document: false do
        before do
          organisations.each do |org|
            create(:edition, :published, document: create(:document), lead_organisation_id: org.id)
          end
        end

        let(:lead_organisation_id) { organisations.first.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq(1)
          expect(data.first["organisation"]["name"]).to eq(organisations.first.name)
          expect(data.first["organisation"]["content_id"]).to eq(organisations.first.id)
        end
      end
    end
  end
end
