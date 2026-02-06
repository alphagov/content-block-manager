RSpec.describe FactCheck::NestedBlockDiffComponent, type: :component do
  let(:schema) { build(:schema, body: { "properties" => { "content_block_block_type" => { "type" => "object", "foo" => { "title" => "" } } } }) }
  let(:field) { spy }
  let(:items) do
    { "title" => { "published" => "something", "new" => "something else" },
      "url" => { "new" => "https://example.com" },
      "label" => { "published" => "My Link" },
      "reviewed" => { "published" => true, "new" => true } }
  end
  let(:component) { described_class.new(items:, field:) }

  before do
    allow(field).to receive(:nested_field).with("title").and_return(double(label: "Title", hidden?: false))
    allow(field).to receive(:nested_field).with("url").and_return(double(label: "URL", hidden?: false))
    allow(field).to receive(:nested_field).with("label").and_return(double(label: "Label", hidden?: false))
    allow(field).to receive(:nested_field).with("reviewed").and_return(double(label: "Reviewed", hidden?: true))
    render_inline(component)
  end

  describe "when given flat items to render" do
    it "should render a summary card with a row for each item passed in" do
      expect(page).to have_css(".gem-c-summary-card", count: 1) do |element|
        expect(element).to have_css(".govuk-summary-list__row", count: 3)
      end
    end

    it "should render the label for each item passed in" do
      expect(page).to have_css(".govuk-summary-list__row", text: "Title")
      expect(page).to have_css(".govuk-summary-list__row", text: "URL")
      expect(page).to have_css(".govuk-summary-list__row", text: "Label")
    end

    it "should not render items that are marked as hidden" do
      expect(page).not_to have_css(".govuk-summary-list__row", text: "Reviewed")
    end

    it "should render a diff of the items for each item passed in" do
      expect(page).to have_css(".compare-editions", count: 3)

      elements = page.find_all(".compare-editions")
      expect(elements.length).to eq(3)
      expect(elements[0]).to have_css(".diff del", text: "something")
      expect(elements[0]).to have_css(".diff ins", text: "something else")
      expect(elements[0]).to have_css(".diff ins strong", text: " else")

      expect(elements[1]).not_to have_css(".diff del")
      expect(elements[1]).to have_css(".diff ins", text: "https://example.com")

      expect(elements[2]).to have_css(".diff del", text: "My Link")
      expect(elements[2]).not_to have_css(".diff ins")
    end
  end

  describe "when given nested fields" do
    let(:super_field) { spy }
    let(:super_items) { { "my-link-1" => items } }
    let(:component) { described_class.new(items: super_items, field: super_field) }

    before do
      allow(super_field).to receive(:nested_field).with("my-link-1").and_return(field)
      render_inline(component)
    end

    it "should render a nested summary card for each level of nesting" do
      summary_cards = page.find_all(".gem-c-summary-card")
      parent_card = summary_cards[0]
      child_card = summary_cards[1]

      expect(parent_card).to have_css(".gem-c-summary-card", count: 1)

      expect(child_card).to have_css(".govuk-summary-list__row", text: "Title")
      expect(child_card).to have_css(".govuk-summary-list__row", text: "URL")
      expect(child_card).to have_css(".govuk-summary-list__row", text: "Label")
    end
  end
end
