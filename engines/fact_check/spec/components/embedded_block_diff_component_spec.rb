RSpec.describe FactCheck::EmbeddedBlockDiffComponent, type: :component do
  let(:items_new) { {} }
  let(:items_published) { {} }

  let(:object_type) { "example_type" }
  let(:object_title) { "Example Title" }

  let(:subschema_body) do
    { "properties" => { "amount" => { "type" => "string", "x-input-prefix" => "£" } } }
  end
  let(:subschema) { build(:embedded_schema, body: subschema_body) }

  let(:schema) { double(:schema) }

  let(:document) { build(:document) }

  let(:items) { CombinedEditionDetails.new(published_details: items_published, new_details: items_new).content }

  before do
    allow(document).to receive(:schema).and_return(schema)
  end

  describe "when there is no data to render" do
    before do
      render_inline(described_class.new(items:, object_type:, object_title:, document:))
    end

    it "should not render the card" do
      expect(page).not_to have_css(".govuk-summary-card")
    end
  end

  describe "when there is data to render" do
    let(:items_new) { { "amount" => "12.34" } }

    before do
      allow(schema).to receive(:subschema).with(object_type).and_return(subschema)
      render_inline(described_class.new(items:, object_type:, object_title:, document:))
    end

    it "should render the card" do
      expect(page).to have_css(".govuk-summary-card")
    end

    it "should render the title" do
      expect(page).to have_css(".govuk-summary-card__title", text: "Example type block")
    end

    it "should render a summary row" do
      expect(page).to have_summary_row.with_key("Amount").with_value("£12.34")
    end

    describe "when the block has a published edition and a newer unpublished edition" do
      let(:items_new) { { "amount" => "12.34" } }
      let(:items_published) { { "amount" => "1.234" } }

      it "should render the diff between the two editions" do
        expect(page).to have_summary_row.with_key("Amount").with_css(".compare-editions .diff.del", text: "£1.234")
        expect(page).to have_summary_row.with_key("Amount").with_css(".compare-editions .diff.ins", text: "£12.34")
      end
    end

    describe "when the block does not have a published edition" do
      let(:items_new) { { "amount" => "12.34" } }
      let(:items_published) { {} }

      it "should render only the new edition with no diff" do
        expect(page).to have_summary_row.with_key("Amount").not_with_css(".compare-editions")
        expect(page).to have_summary_row.with_key("Amount").with_value("£12.34")
      end
    end

    describe "when there are nested items" do
      let(:subschema_body) do
        {
          "properties" => {
            "rates" => {
              "type" => "object",
              "properties" => {
                "name" => { "type" => "string" },
                "value" => { "type" => "string" },
                "bands" => {
                  "type" => "array",
                  "items" => {
                    "type" => "object",
                    "properties" => {
                      "name" => { "type" => "string" },
                      "lower_threshold" => {
                        "type" => "object",
                        "properties" => {
                          "value" => { "type" => "string" },
                        },
                      },
                      "upper_threshold" => {
                        "type" => "object",
                        "properties" => {
                          "value" => { "type" => "string" },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        }
      end

      let(:items_new) do
        {
          "rates" => [
            {
              "name" => "Personal allowance",
              "value" => "0%",
              "bands" => [
                {
                  "name" => "Personal allowance band",
                  "upper_threshold" => {
                    "value" => "£12,570",
                  },
                },
              ],
            },
            {
              "name" => "Basic rate",
              "value" => "20%",
              "bands" => [
                {
                  "name" => "Basic rate band",
                  "lower_threshold" => {
                    "value" => "£12,571",
                  },
                  "upper_threshold" => {
                    "value" => "£50,270",
                  },
                },
              ],
            },
          ],
        }
      end

      it "should render the values nested within the card" do
        expect(page).to have_css(".govuk-summary-card__content") do |summary_card_content|
          # binding.pry
          expect(summary_card_content).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Rate 1/) do |rate_details|
            expect(rate_details).to have_summary_row.with_key("Name") do |row|
              expect row.to have_css(".visually-hidden", text: "Added content")
              expect row.to have_content "Added content Personal allowance"
            end

            expect(rate_details).to have_summary_row.with_key("Value") do |row|
              expect row.to have_css(".visually-hidden", text: "Added content")
              expect row.to have_content "Added content 0%"
            end

            expect(rate_details).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Band 1/) do |band_details|
              expect(band_details).to have_summary_row.with_key("Name") do |row|
                expect row.to have_css(".visually-hidden", text: "Added content")
                expect row.to have_content "Added content Personal allowance band"
              end

              expect(band_details).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Upper threshold/) do |upper_threshold_details|
                expect(upper_threshold_details).to have_summary_row.with_key("Value") do |row|
                  expect row.to have_css(".visually-hidden", text: "Added content")
                  expect row.to have_content "Added content £12,570"
                end
              end
            end
          end

          expect(summary_card_content).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Rate 2/) do |rate_details|
            expect(rate_details).to have_summary_row.with_key("Name") do |row|
              expect row.to have_css(".visually-hidden", text: "Added content")
              expect row.to have_content "Added content Basic rate"
            end

            expect(rate_details).to have_summary_row.with_key("Value") do |row|
              expect row.to have_css(".visually-hidden", text: "Added content")
              expect row.to have_content "Added content 20%"
            end

            expect(rate_details).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Band 1/) do |band_details|
              expect(band_details).to have_summary_row.with_key("Name") do |row|
                expect row.to have_css(".visually-hidden", text: "Added content")
                expect row.to have_content "Added content Basic rate band"
              end

              expect(band_details).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Lower threshold/) do |lower_threshold_details|
                expect(lower_threshold_details).to have_summary_row.with_key("Value") do |row|
                  expect row.to have_css(".visually-hidden", text: "Added content")
                  expect row.to have_content "Added content £12,571"
                end
              end

              expect(band_details).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Upper threshold/) do |upper_threshold_details|
                expect(upper_threshold_details).to have_summary_row.with_key("Value") do |row|
                  expect row.to have_css(".visually-hidden", text: "Added content")
                  expect row.to have_content "Added content £50,270"
                end
              end
            end
          end
        end
      end

      context "when a published version exists" do
        let(:items_published) do
          {
            "rates" => [
              {
                "name" => "Personal allowance",
                "value" => "0%",
                "bands" => [
                  {
                    "name" => "Personal allowance band",
                    "upper_threshold" => {
                      "value" => "£12,550",
                    },
                  },
                ],
              },
              {
                "name" => "Basic rate",
                "value" => "20%",
                "bands" => [
                  {
                    "name" => "Basic rate band",
                    "lower_threshold" => {
                      "value" => "£12,571",
                    },
                    "upper_threshold" => {
                      "value" => "£50,270",
                    },
                  },
                ],
              },
            ],
          }
        end

        it "shows a diff of the changed values" do
          expect(page).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Band 1/) do |band_details|
            expect(band_details).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Upper threshold/) do |upper_threshold_details|
              expect(upper_threshold_details).to have_summary_row.with_key("Value")
                                                                 .with_css(".compare-editions .diff.del", text: "£12,550")
              expect(upper_threshold_details).to have_summary_row.with_key("Value")
                                                                 .with_css(".compare-editions .diff.ins", text: "£12,570")
            end
          end
        end
      end
    end
  end
end
