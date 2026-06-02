require "swagger_helper"

RSpec.describe "API" do
  path "/blocks/search" do
    let(:organisations) do
      [
        build(:organisation, id: "aa1b2c3d-1234-5678-abcd-000000000001", name: "HM Revenue & Customs"),
        build(:organisation, id: "aa1b2c3d-1234-5678-abcd-000000000002", name: "Foreign, Commonwealth & Development Office"),
        build(:organisation, id: "aa1b2c3d-1234-5678-abcd-000000000003", name: "Department for Work and Pensions"),
      ]
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

      parameter name: "block_type", in: :query, type: :string, required: false, description: "The type of block to filter by. This is a case-insensitive match against the block type defined in the document associated with the content block."
      parameter name: "lead_organisation_id", in: :query, type: :string, required: false, description: "The Content ID of the lead organisation to filter by."
      parameter name: "keyword", in: :query, type: :string, required: false, description: "The keyword to filter by. Searches against the title and the details hash of the content block."
      parameter name: "page", in: :query, type: :string, required: false, description: "The page number to return. Defaults to 1."

      # Overrides the `page` method included in all request specs in spec/support/capybara.rb to prevent it from being
      # called when the `page` parameter is used in the tests
      let(:page) { nil }

      response "200", "blocks found" do
        before do
          create(
            :edition,
            :published,
            title: "Current Tax Year",
            document: create(:document, block_type: "time_period", sluggable_string: "current-tax-year"),
            lead_organisation_id: organisations.first.id,
          )
        end

        schema type: :object,
               additionalProperties: false,
               properties: {
                 total: { type: :integer },
                 pages: { type: :integer },
                 current_page: { type: :integer },
                 links: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       href: { type: :string },
                       rel: { type: :string, enum: %w[self next previous] },
                     },
                   },
                 },
                 results: {
                   type: :array,
                   items: {
                     type: :object,
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
                   },
                 },
               }

        after do |example|
          content = example.metadata[:response][:content] || {}
          example.metadata[:response][:content] = content.merge(
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          )
        end

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
          it_returns_correct_pagination_information(
            data,
            total: 1,
            pages: 1,
            current_page: 1,
            expected_links: [{ rel: "self", href: "http://www.example.com/api/blocks/search?block_type=pension&page=1" }],
          )

          expect(data["results"].size).to eq(1)
          expect(data["results"].first["block_type"]).to eq("Pension")
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
          it_returns_correct_pagination_information(
            data,
            total: 1,
            pages: 1,
            current_page: 1,
            expected_links: [{ rel: "self", href: "http://www.example.com/api/blocks/search?lead_organisation_id=#{lead_organisation_id}&page=1" }],
          )

          expect(data["results"].size).to eq(1)
          expect(data["results"].first["organisation"]["name"]).to eq(organisations.first.name)
          expect(data["results"].first["organisation"]["content_id"]).to eq(organisations.first.id)
        end
      end

      response "200", "filters by keyword", document: false do
        before do
          create(:edition, :published, document: create(:document), lead_organisation_id: organisations.first.id, title: "first")
          create(:edition, :published, document: create(:document), lead_organisation_id: organisations.first.id, title: "second")
        end

        let(:keyword) { "first" }

        run_test! do |response|
          data = JSON.parse(response.body)
          it_returns_correct_pagination_information(
            data,
            total: 1,
            pages: 1,
            current_page: 1,
            expected_links: [{ rel: "self", href: "http://www.example.com/api/blocks/search?keyword=first&page=1" }],
          )

          expect(data["results"].size).to eq(1)
          expect(data["results"].first["title"]).to eq("first")
        end
      end

      context "pagination" do
        before do
          # Stub the default page size to 1 so that we can test pagination with a small number of records
          stub_const("ContentBlock::Query::DEFAULT_PAGE_SIZE", 1)
          3.times { create(:edition, :published, document: create(:document), lead_organisation_id: organisations.first.id) }
        end

        response "200", "returns the first page", document: false do
          let(:page) { 1 }

          run_test! do |response|
            data = JSON.parse(response.body)
            it_returns_correct_pagination_information(
              data,
              total: 3,
              pages: 3,
              current_page: 1,
              expected_links: [
                { rel: "next", href: "http://www.example.com/api/blocks/search?page=2" },
                { rel: "self", href: "http://www.example.com/api/blocks/search?page=1" },
              ],
            )
          end
        end

        response "200", "returns the second page", document: false do
          let(:page) { 2 }

          run_test! do |response|
            data = JSON.parse(response.body)
            it_returns_correct_pagination_information(
              data,
              total: 3,
              pages: 3,
              current_page: 2,
              expected_links: [
                { rel: "previous", href: "http://www.example.com/api/blocks/search?page=1" },
                { rel: "next", href: "http://www.example.com/api/blocks/search?page=3" },
                { rel: "self", href: "http://www.example.com/api/blocks/search?page=2" },
              ],
            )
          end
        end

        response "200", "returns the last page", document: false do
          let(:page) { 3 }

          run_test! do |response|
            data = JSON.parse(response.body)
            it_returns_correct_pagination_information(
              data,
              total: 3,
              pages: 3,
              current_page: 3,
              expected_links: [
                { rel: "previous", href: "http://www.example.com/api/blocks/search?page=2" },
                { rel: "self", href: "http://www.example.com/api/blocks/search?page=3" },
              ],
            )
          end
        end
      end

      context "invalid page numbers" do
        before do
          create(:edition, :published, document: create(:document), lead_organisation_id: organisations.first.id)
        end

        response "200", "returns empty results for out-of-range page", document: false do
          let(:page) { 999 }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data["results"]).to be_empty
            expect(data["total"]).to eq(1)
            expect(data["current_page"]).to eq(999)
          end
        end

        response "400", "returns error for negative page number", document: false do
          let(:page) { -1 }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data["error"]).to be_present
          end
        end

        response "400", "returns error for zero page number", document: false do
          let(:page) { 0 }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data["error"]).to be_present
          end
        end
      end
    end
  end

  def it_returns_correct_pagination_information(data, total:, pages:, current_page:, expected_links:)
    expect(data["total"]).to eq(total)
    expect(data["pages"]).to eq(pages)
    expect(data["current_page"]).to eq(current_page)
    expect(data["links"].size).to eq(expected_links.size)
    expected_links.each_with_index do |link, index|
      expect(data["links"][index]["rel"]).to eq(link[:rel])
      expect(data["links"][index]["href"]).to eq(link[:href])
    end
  end

  let(:organisations) { build_list(:organisation, 1) }

  describe "GET /api/blocks/render" do
    let(:document1) { create(:document, sluggable_string: "state-pension", block_type: "pension") }
    let(:document2) { create(:document, sluggable_string: "tax-year", block_type: "pension") } # Using pension as I know it's supported

    before do
      create(:edition, :published, document: document1, title: "State Pension", lead_organisation_id: organisations.first.id)
      create(:edition, :published, document: document2, title: "Tax year", lead_organisation_id: organisations.first.id)
    end

    it "returns rendered html for given embed codes" do
      embed_codes = [document1.embed_code, document2.embed_code]

      get "/api/blocks/render", params: { embed_codes: }

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)

      expect(data).to have_key("rendered_blocks")
      expect(data["rendered_blocks"]).to have_key(document1.embed_code)
      expect(data["rendered_blocks"]).to have_key(document2.embed_code)

      expect(data["rendered_blocks"][document1.embed_code]).to include(
        "title" => "State Pension",
        "block_type" => "Pension",
      )
      expect(data["rendered_blocks"][document1.embed_code]["html"]).to be_a(String)
      expect(data["rendered_blocks"][document1.embed_code]["html"]).to include("State Pension")

      expect(data["rendered_blocks"][document2.embed_code]).to include(
        "title" => "Tax year",
        "block_type" => "Pension",
      )
      expect(data["rendered_blocks"][document2.embed_code]["html"]).to be_a(String)
      expect(data["rendered_blocks"][document2.embed_code]["html"]).to include("Tax year")
    end

    it "ignores unknown embed codes" do
      get "/api/blocks/render", params: { embed_codes: ["{{embed:unknown}}"] }

      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)

      expect(data).to eq("rendered_blocks" => {})
    end

    it "renders blocks for embed code variants using the base embed code lookup" do
      variant_embed_code = "#{document1.embed_code}#section-a"

      get "/api/blocks/render", params: { embed_codes: [variant_embed_code] }

      expect(response).to have_http_status(:ok)

      data = JSON.parse(response.body)

      expect(data["rendered_blocks"]).to have_key(variant_embed_code)
      expect(data["rendered_blocks"][variant_embed_code]).to include(
        "title" => "State Pension",
        "block_type" => "Pension",
      )
      expect(data["rendered_blocks"][variant_embed_code]["html"]).to be_a(String)
      expect(data["rendered_blocks"][variant_embed_code]["html"]).to include("State Pension")
    end
  end
end
