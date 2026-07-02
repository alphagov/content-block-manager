require "swagger_helper"
require "cgi"

RSpec.describe "API" do
  path "/blocks" do
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
        keyword.
      DESC

      tags "Content Blocks"
      produces "application/json"

      parameter name: "block_type", in: :query, type: :string, required: false, description: "The type of block to filter by. This is a case-insensitive match against the block type defined in the document associated with the content block."
      parameter name: "lead_organisation_id", in: :query, type: :string, required: false, description: "The Content ID of the lead organisation to filter by."
      parameter name: "keyword", in: :query, type: :string, required: false, description: "The keyword to filter by. Searches against the title and the details hash of the content block."

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
          expect(data["results"].size).to eq(1)
          expect(data["results"].first["title"]).to eq("first")
        end
      end
    end
  end

  path "/blocks/{embed_code}/render" do
    get "Render a content block" do
      description <<~DESC
        This endpoint renders a published content block as HTML for a given embed code.
      DESC

      tags "Content Blocks"
      produces "text/html", "application/json"

      parameter name: "embed_code", in: :path, type: :string, required: true, description: "The embed code to render. This can be a base embed code or one that targets a specific field or format."

      def normalise_html(html)
        fragment = Nokogiri::HTML.fragment(html)
        fragment.traverse do |node|
          if node.text?
            node.content = node.content.squish
            node.remove if node.content.empty?
          end
        end
        fragment.to_html
      end

      response "200", "renders HTML for a base embed code" do
        before do
          @document = create(
            :document,
            block_type: "pension",
            sluggable_string: "state-pension",
            content_id: "11111111-2222-4333-8444-555555555555",
          )
          create(
            :edition,
            :published,
            title: "State Pension",
            lead_organisation_id: SecureRandom.uuid,
            document: @document,
          )
        end

        let(:embed_code) { CGI.escape(@document.embed_code) }

        after do |example|
          content = example.metadata[:response][:content] || {}
          example.metadata[:response][:content] = content.deep_merge(
            "text/html" => {
              examples: {
                base_embed_code: {
                  summary: "Base embed code renders the block title",
                  value: response.body,
                },
              },
            },
          )
        end

        run_test! do |response|
          expect(response.content_type).to include("text/html")
          expect(response.body).to include("content-block")
          expect(response.body).to include("State Pension")
        end
      end

      response "200", "renders the specified sub content for an internal content path" do
        before do
          @document = create(
            :document,
            block_type: "pension",
            sluggable_string: "state-pension-field",
            content_id: "11111111-2222-4333-8444-666666666666",
          )
          create(
            :edition,
            :published,
            details: {
              "rates" => {
                "weekly-rate" => {
                  "title" => "Weekly rate",
                  "amount" => "999.69",
                  "frequency" => "a week",
                },
              },
            },
            title: "State Pension",
            lead_organisation_id: SecureRandom.uuid,
            document: @document,
          )
        end

        let(:embed_code) { CGI.escape(@document.embed_code_for_field("rates/weekly-rate/amount")) }

        let(:expected_response) do
          <<~HTML
            <span
              class="content-block content-block--pension"
              data-content-block=""
              data-document-type="pension"
              data-content-id="11111111-2222-4333-8444-666666666666"
              data-embed-code="{{embed:content_block_pension:state-pension-field/rates/weekly-rate/amount}}"
              >
              £999.69
            </span>
          HTML
        end

        after do |example|
          content = example.metadata[:response][:content] || {}
          example.metadata[:response][:content] = content.deep_merge(
            "text/html" => {
              examples: {
                internal_content_path: {
                  summary: "Providing an internal path causes the correct path to be rendered",
                  value: response.body,
                },
              },
            },
          )
        end

        run_test! do |response|
          expect(response.content_type).to include("text/html")
          expect(normalise_html(response.body)).to eq(normalise_html(expected_response))
        end
      end

      response "200", "renders the specified sub content for a format" do
        before do
          @document = create(
            :document,
            block_type: "time_period",
            sluggable_string: "sample_time_period",
            content_id: "11111111-2222-5333-8444-666666666666",
          )
          create(
            :edition,
            :published,
            details:
            {
              "date_range" => {
                "start" => "2109-09-09T07:00:00+01:00",
                "end" => "2109-10-10T10:00:00+01:00",
              },
            },
            title: "Sample Time Period",
            lead_organisation_id: SecureRandom.uuid,
            document: @document,
          )
        end

        let(:embed_code) { CGI.escape(@document.embed_code_for_format("long_form")) }

        let(:expected_response) do
          <<~HTML
            <div
              class="content-block content-block--time_period"
              data-content-block=""
              data-document-type="time_period"
              data-content-id="11111111-2222-5333-8444-666666666666"
              data-embed-code="{{embed:content_block_time_period:sample_time_period#long_form}}"
              >
              <p class="govuk-body">9 September 2109 to 10 October 2109</p>
            </div>
          HTML
        end

        after do |example|
          content = example.metadata[:response][:content] || {}
          example.metadata[:response][:content] = content.deep_merge(
            "text/html" => {
              examples: {
                format: {
                  summary: "Providing a format causes the correct format to be rendered",
                  value: response.body,
                },
              },
            },
          )
        end

        run_test! do |response|
          expect(response.content_type).to include("text/html")
          expect(normalise_html(response.body)).to eq(normalise_html(expected_response))
        end
      end

      response "404", "returns an error when the embed code is unknown" do
        let(:embed_code) { CGI.escape("{{embed:content_block_pension:missing-block}}") }

        run_test! do |response|
          data = JSON.parse(response.body)

          expect(data).to eq({
            "error" => "Content block not found for embed code: {{embed:content_block_pension:missing-block}}",
          })
        end
      end

      response "404", "returns an error when the embed code with an internal content path path is unknown", document: false do
        let(:embed_code) { CGI.escape("{{embed:content_block_pension:missing-block/rates/rate1/amount}}}") }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["error"]).to be_present
        end
      end
    end
  end
end
