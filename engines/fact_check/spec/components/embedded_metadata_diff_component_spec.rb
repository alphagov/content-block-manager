RSpec.describe FactCheck::EmbeddedMetadataDiffComponent, type: :component do
  let(:schema) { build(:schema, body: { "properties" => { "title" => "", "frequency" => "" } }) }
  let(:items) { {} }
  let(:items_published) { nil }
  let(:subschema) { build(:schema) }
  let(:component) { described_class.new(schema:, items:, items_published:) }

  describe "when there is no data to render" do
    it "should not render the summary list component" do
      render_inline(component)

      expect(page).to have_css(".app-c-embedded-objects-metadata-component") do |element|
        expect(element).not_to have_css(".govuk-summary-list")
      end
    end
  end

  describe "when there is data to render" do
    describe "when the block has a published edition and a newer unpublished edition" do
      let(:items) { { "title" => "some new title", "frequency" => "a week" } }
      let(:items_published) { { "title" => "some title", "frequency" => "a day" } }
      before do
        render_inline(component)
      end

      it "should render the diff between the two editions" do
        expect(page).to have_css(".govuk-summary-list")

        diff_blocks = page.find_css(".compare-editions")

        expect(diff_blocks[0]).to have_css(".diff del", text: "some title")
        expect(diff_blocks[0]).to have_css(".diff ins", text: "some new title")

        expect(diff_blocks[1]).to have_css(".diff del", text: "a day")
        expect(diff_blocks[1]).to have_css(".diff ins", text: "a week")
      end
    end

    describe "when the block does not have a published edition" do
      let(:items) { { "title" => "some new title", "frequency" => "a week" } }
      let(:items_published) { nil }

      it "should render only the new edition with no diff" do
        render_inline(component)

        expect(page).to have_css(".govuk-summary-list")
        diff_blocks = page.find_css(".compare-editions")
        expect(diff_blocks[0]).not_to have_css(".diff")
        expect(diff_blocks[0]).to have_text("some new title")

        expect(diff_blocks[1]).not_to have_css(".diff")
        expect(diff_blocks[1]).to have_text("a week")
      end
    end
  end
end
