RSpec.describe FactCheck::UngroupedSubschemaDiffComponent, type: :component do
  let(:subschema) do
    build(:schema, body: { "properties" =>
                           {
                             "title" => "",
                             "frequency" => "",
                             "amount" => "",
                           } })
  end
  let(:schema) { build(:schema) }
  let(:document) { build(:document, schema:) }
  let(:display_fields) { %w[amount] }
  let(:edition) do
    build(:edition,
          document: document,
          details: {
            "content_block_block_type" => {
              "my_rate" => {
                "title" => "my title",
                "frequency" => "weekly",
                "amount" => "£1000",
              },
              "my_rate_2" => {
                "title" => "my title 2",
              },
            },
          })
  end
  let(:block) { build(:content_block, schema: subschema, edition:) }
  let(:component) { described_class.new(block:, subschema:) }

  before do
    allow(schema).to receive(:subschema).with("content_block_block_type").and_return(subschema)
    allow(subschema).to receive(:block_display_fields).and_return(display_fields)
  end

  before do
    render_inline(component)
  end

  it "should render the metadata component for each embedded object" do
    metadata_components = page.all(".app-c-embedded-objects-metadata-component")
    expect(metadata_components.length).to be(2)

    expect(metadata_components[0]).to have_css(".govuk-summary-list__row", count: 2)
    expect(metadata_components[0]).to have_content("my title")
    expect(metadata_components[0]).to have_content("weekly")
    expect(metadata_components[0]).not_to have_content("£1000")

    expect(metadata_components[1]).to have_css(".govuk-summary-list__row", count: 1)
    expect(metadata_components[1]).to have_content("my title 2")
  end

  it "should render the block component for each embedded object" do
    blocks_components = page.all(".app-c-embedded-objects-blocks-component")
    expect(blocks_components.length).to be(2)

    expect(blocks_components[0]).to have_css(".govuk-summary-list__row", count: 1)
    expect(blocks_components[0]).to have_content("£1000")

    expect(blocks_components[1]).to have_css(".govuk-summary-list__row", count: 0)
  end
end
