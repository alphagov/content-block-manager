RSpec.describe FactCheck::BlocksController, type: :feature do
  include FactCheck::Engine.routes.url_helpers

  let(:document) { create(:document) }
  let(:current_edition) { create(:edition, document:) }
  let(:published_edition) { create(:edition, document:) }
  let(:subschemas) do
    [
      double(:subschema, id: "email_addresses", block_type: "email_addresses", group_order: 1),
      double(:subschema, id: "telephones", block_type: "telephones", group_order: 2),
      double(:subschema, id: "addresses", block_type: "addresses", group_order: 3),
      double(:subschema, id: "contact_links", block_type: "contact_links", group_order: 4),
    ]
  end
  let(:schema) { double(:schema, subschemas: subschemas, embeddable_as_block?: true, body: {}) }

  before do
    logout
    user = create(:user)
    login_as(user)
    allow(Document).to receive(:find).and_return(document)
    allow(document).to receive(:schema).and_return(schema)
    allow(document).to receive(:most_recent_edition).and_return(current_edition)
    allow(document).to receive(:latest_published_edition).and_return(published_edition)
    allow(Schema).to receive(:find_by_block_type).and_return(schema)
  end

  describe "#show" do
    it "returns information about a block" do
      block = build(:content_block)
      expect(ContentBlock).to receive(:from_content_id_alias).with("some-content-block").and_return(block)

      visit block_path("some-content-block")

      expect(page).to have_css ".govuk-heading-xl", text: block.title
      expect(page).to have_css ".govuk-caption-xl", text: block.block_type
      expect(page).to have_css ".govuk-tag--pink", text: "In factcheck"
      expect(page).to have_css ".govuk-summary-card__title", text: "Default block"
    end
  end
end
