require "test_helper"

class Shared::ContinueOrCancelButtonGroupTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  let(:form_id) { "my_form_id" }
  let(:edition) { build_stubbed(:edition, document: build_stubbed(:document)) }

  let(:component) do
    Shared::ContinueOrCancelButtonGroup.new(form_id:, edition:)
  end

  describe "when an edition is for a brand new document" do
    before do
      edition.document.stubs(:editions).returns([edition])
    end

    it "renders with the correct form ID and URLs" do
      render_inline component

      assert_selector "button[form='my_form_id']", text: "Save and continue"
      assert_selector "form[action='#{edition_path(
        edition,
        redirect_path: documents_path,
      )}']"
    end

    describe "when custom button text is provided" do
      let(:button_text) { "My custom text" }
      let(:component) do
        Shared::ContinueOrCancelButtonGroup.new(form_id:, edition:, button_text:)
      end

      it "renders with custom button text" do
        render_inline component

        assert_selector "button[form='my_form_id']", text: button_text
      end
    end
  end

  describe "when an edition is for an existing document" do
    before do
      edition.document.stubs(:editions).returns([*edition, build_stubbed_list(:edition, 2)])
    end

    it "renders with a link to the cancel page" do
      render_inline component

      assert_selector "button[form='my_form_id']", text: "Save and continue"
      assert_selector "a[href='#{cancel_workflow_index_path(edition)}']"
    end
  end
end
