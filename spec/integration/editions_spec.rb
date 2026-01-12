require "capybara/rails"

RSpec.describe Editions, type: :feature do
  include Rails.application.routes.url_helpers

  before do
    login_as_admin
  end

  describe "#new" do
    let(:organisation) { build(:organisation) }

    before do
      allow(Organisation).to receive(:all).and_return([organisation])
    end

    describe "when a document id is provided" do
      let!(:original_edition) { create(:edition, :pension, document: document) }
      let(:document) { create(:document, :pension) }

      before do
        document.latest_published_edition = original_edition
        document.save!
      end

      scenario "initializes the form for the latest edition" do
        expect(Document).to receive(:find).with(document.id.to_s).and_return(document)
        schema = stub_request_for_schema(document.block_type)
        form = double(:form, title: "title", url: "url", back_path: "back_path", edition: original_edition, schema:, attributes: {}, form_method: :post)
        expect(EditionForm).to receive(:for).with(
          edition: original_edition,
          schema:,
        ).and_return(form)

        visit new_document_edition_path(document)

        assert_text document.title
      end
    end

    describe "when a document id is not provided" do
      scenario "initializes the form for the latest edition" do
        edition = create(:edition, :pension)
        expect(Edition).to receive(:new).and_return(edition)
        schema = stub_request_for_schema("block_type")
        form = double(:form, title: "title", url: "url", back_path: "back_path", edition: edition, schema:, attributes: {}, form_method: :post)
        expect(EditionForm).to receive(:for).with(
          edition: edition,
          schema:,
        ).and_return(form)

        visit new_edition_path(block_type: "block-type")

        assert_text "Create content block"
      end
    end
  end

  describe "#preview" do
    let(:embed_code) { "EMBED_CODE" }
    let(:document) { build(:document) }
    let(:edition) { build_stubbed(:edition, document: document) }

    before do
      allow(document).to receive(:embed_code).and_return(embed_code)
      allow(Edition).to receive(:find).with(edition.id.to_s).and_return(edition)
      allow(edition).to receive(:render).with(document.embed_code).and_return("RENDERED_BLOCK")
      allow(edition).to receive(:has_multiple_subschema_entries?).and_return(true)
    end

    scenario "renders a preview of the edition" do
      visit preview_edition_path(edition)

      expect(page).to have_css ".app-views-editions-preview .govspeak", text: "RENDERED_BLOCK"
    end

    scenario "shows a link to reorder if has_multiple_subschema_entries? is true" do
      allow(edition).to receive(:has_multiple_subschema_entries?).and_return(true)
      visit preview_edition_path(edition)

      expect(page).to have_css "a.govuk-button", text: "Reorder"
    end

    scenario "shows NO link to reorder if has_multiple_subschema_entries? is false" do
      allow(edition).to receive(:has_multiple_subschema_entries?).and_return(false)
      visit preview_edition_path(edition)

      assert_no_selector "a.govuk-button", text: "Reorder"
    end
  end
end
