RSpec.describe Shared::DeleteDraftComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:edition) { build_stubbed(:edition, id: 123, document: build_stubbed(:document, id: 456)) }

  let(:component) do
    described_class.new(edition:)
  end

  describe "when an edition is for a brand new document" do
    before do
      allow(edition.document).to receive(:editions).and_return([edition])
    end

    it "renders a form to delete the draft" do
      render_inline component

      expect(page).to have_css "input[name='_method'][value='delete']", visible: false
      expect(page).to have_css "form[action*='/editions/123']"
    end

    it "renders a form which redirects to the homepage after deletion" do
      render_inline component
      expected_path = "/"

      expect(page).to have_css "form[action*='redirect_path=#{URI.encode_uri_component(expected_path)}']"
    end
  end

  describe "when an edition is for an existing document" do
    before do
      allow(edition.document).to receive(:editions).and_return([*edition, build_stubbed_list(:edition, 2)])
    end

    it "renders a form to delete the draft" do
      render_inline component

      expect(page).to have_css "input[name='_method'][value='delete']", visible: false
      expect(page).to have_css "form[action*='/editions/123']"
    end

    it "renders a form which redirects to the homepage after deletion" do
      render_inline component
      expected_path = "/456"

      expect(page).to have_css "form[action*='redirect_path=#{URI.encode_uri_component(expected_path)}']"
    end
  end
end
