RSpec.describe Shared::ContinueOrCancelButtonGroup, type: :component do
  include Rails.application.routes.url_helpers

  let(:form_id) { "my_form_id" }
  let(:edition) { build_stubbed(:edition, document: build_stubbed(:document)) }

  let(:component) do
    described_class.new(form_id:, edition:)
  end

  describe "when an edition is for a brand new document" do
    before do
      allow(edition.document).to receive(:editions).and_return([edition])
    end

    it "renders with the correct form ID and URLs" do
      render_inline component

      expect(page).to have_css "button[form='my_form_id']", text: "Save and continue"
      expect(page).to have_css "form[action='#{edition_path(
        edition,
        redirect_path: documents_path,
      )}']"
    end

    describe "when custom button text is provided" do
      let(:button_text) { "My custom text" }
      let(:component) do
        described_class.new(form_id:, edition:, button_text:)
      end

      it "renders with custom button text" do
        render_inline component

        expect(page).to have_css "button[form='my_form_id']", text: button_text
      end
    end
  end

  describe "when an edition is for an existing document" do
    before do
      allow(edition.document).to receive(:editions).and_return([*edition, build_stubbed_list(:edition, 2)])
    end

    it "renders with a link to the cancel page" do
      render_inline component

      expect(page).to have_css "button[form='my_form_id']", text: "Save and continue"
      expect(page).to have_css "a[href='#{cancel_workflow_index_path(edition)}']"
    end
  end
end
