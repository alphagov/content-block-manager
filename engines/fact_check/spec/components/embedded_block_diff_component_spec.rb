RSpec.describe FactCheck::EmbeddedBlockDiffComponent, type: :component do
  let(:items) { {} }
  let(:items_published) { nil }
  let(:object_type) { "example_type" }
  let(:object_title) { "Example Title" }
  let(:subschema) { build(:schema, body: { "properties" => { "amount" => "" } }) }
  let(:schema) { double(:schema) }
  let(:document) { build(:document, schema:) }

  describe "when there is no data to render" do
    before do
      render_inline(described_class.new(items:, items_published:, object_type:, object_title:, document:))
    end

    it "should not render the card" do
      expect(page).not_to have_css(".govuk-summary-card")
    end
  end

  describe "when there is data to render" do
    let(:items) { { "amount" => "£12.34" } }

    before do
      allow(schema).to receive(:subschema).with(object_type).and_return(subschema)
      render_inline(described_class.new(items:, items_published:, object_type:, object_title:, document:))
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
      let(:items) { { "amount" => "£12.34" } }
      let(:items_published) { { "amount" => "£1.234" } }

      it "should render the diff between the two editions" do
        expect(page).to have_summary_row.with_key("Amount").with_css(".compare-editions .diff del", text: "£1.234")
        expect(page).to have_summary_row.with_key("Amount").with_css(".compare-editions .diff ins", text: "£12.34")
      end
    end

    describe "when the block does not have a published edition" do
      let(:items) { { "amount" => "£12.34" } }
      let(:items_published) { nil }

      it "should render only the new edition with no diff" do
        expect(page).to have_summary_row.with_key("Amount").not_with_css(".compare-editions .diff")
        expect(page).to have_summary_row.with_key("Amount").with_css(".compare-editions", text: "£12.34")
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

      let(:subschema) { build(:schema, body: subschema_body) }

      let(:items) do
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
          expect(summary_card_content).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Rate 1/) do |rate_details|
            expect(rate_details).to have_summary_row.with_key("Name").with_value("Personal allowance")
            expect(rate_details).to have_summary_row.with_key("Value").with_value("0%")

            expect(rate_details).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Band 1/) do |band_details|
              expect(band_details).to have_summary_row.with_key("Name").with_value("Personal allowance band")

              expect(band_details).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Upper threshold/) do |upper_threshold_details|
                expect(upper_threshold_details).to have_summary_row.with_key("Value").with_value("£12,570")
              end
            end
          end

          expect(summary_card_content).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Rate 2/) do |rate_details|
            expect(rate_details).to have_summary_row.with_key("Name").with_value("Basic rate")
            expect(rate_details).to have_summary_row.with_key("Value").with_value("20%")

            expect(rate_details).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Band 1/) do |band_details|
              expect(band_details).to have_summary_row.with_key("Name").with_value("Basic rate band")

              expect(band_details).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Lower threshold/) do |lower_threshold_details|
                expect(lower_threshold_details).to have_summary_row.with_key("Value").with_value("£12,571")
              end

              expect(band_details).to have_css(".app-c-embedded-objects-blocks-component--nested", text: /Upper threshold/) do |upper_threshold_details|
                expect(upper_threshold_details).to have_summary_row.with_key("Value").with_value("£50,270")
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
                                                                 .with_css(".compare-editions .diff del", text: "£12,550")
              expect(upper_threshold_details).to have_summary_row.with_key("Value")
                                                                 .with_css(".compare-editions .diff ins", text: "£12,570")
            end
          end
        end
      end
    end
  end
end
