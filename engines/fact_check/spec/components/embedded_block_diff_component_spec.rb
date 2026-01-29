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

    it "should render the item label" do
      expect(page).to have_css(".govuk-summary-list__key", text: "Amount")
    end

    describe "when the block has a published edition and a newer unpublished edition" do
      let(:items) { { "amount" => "£12.34" } }
      let(:items_published) { { "amount" => "£1.234" } }

      it "should render the diff between the two editions" do
        expect(page).to have_css(".compare-editions") do |element|
          expect(element).to have_css(".diff del", text: "£1.234")
          expect(element).to have_css(".diff ins", text: "£12.34")
        end
      end
    end

    describe "when the block does not have a published edition" do
      let(:items) { { "amount" => "£12.34" } }
      let(:items_published) { nil }

      it "should render only the new edition with no diff" do
        expect(page).to have_css(".compare-editions") do |element|
          expect(element).not_to have_css(".diff")
          expect(element).to have_text("£12.34")
        end
      end
    end
  end
end
