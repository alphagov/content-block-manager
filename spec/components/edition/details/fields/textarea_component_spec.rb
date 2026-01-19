COMPONENT_CLASS = ".app-c-content-block-manager-textarea-component".freeze

RSpec.describe Edition::Details::Fields::TextareaComponent, type: :component do
  let(:edition) { build(:edition, :pension) }
  let(:field) { build("field", name: "email_address", is_required?: true, default_value: nil, label: "Email address") }
  let(:schema) { double(:schema, block_type: "schema") }

  let(:context) do
    Edition::Details::Fields::Context.new(edition:, field:, schema:)
  end

  let(:described_class) { Edition::Details::Fields::TextareaComponent }

  let(:component) { described_class.new(context) }

  context "when the field is govspeak enabled" do
    before do
      allow(field).to receive(:govspeak_enabled?).and_return(true)
    end

    it_behaves_like "a field component", field_type: "textarea"

    context "and the field does not have a character limit" do
      it "displays guidance to indicate 'Govspeak supported'" do
        render_inline component

        expect(page).to have_css(COMPONENT_CLASS) do |component|
          expect(component).to have_css(
            ".guidance.govspeak-supported",
            text: I18n.t("edition.hints.govspeak_enabled"),
          )
        end
      end
    end

    context "and the field has a character limit" do
      before do
        allow(field).to receive(:config).and_return({ "character_limit" => 500 })
      end
      it "does not display guidance to indicate 'Govspeak supported'" do
        render_inline component

        expect(page).to have_css(COMPONENT_CLASS) do |component|
          expect(component).not_to have_css(
            ".guidance.govspeak-supported",
            text: I18n.t("edition.hints.govspeak_enabled"),
          )
        end
      end
    end

    describe "hint ID mapping to textarea 'aria-describedby'" do
      let(:expected_hint_id_to_aria_mapping) do
        "#{context.id}-hint"
      end

      it "includes an 'aria-describedby' attribute on the textarea, to match the label hint's ID" do
        render_inline component

        expect(page).to have_css(COMPONENT_CLASS) do |component|
          expect(component).to have_css(
            "textarea[aria-describedby='#{expected_hint_id_to_aria_mapping}']",
          )
        end
      end

      it "includes a 'Preview' button" do
        render_inline component

        expect(page).to have_css(COMPONENT_CLASS) do |component|
          expect(component).to have_css(
            "button.js-app-c-govspeak-editor__preview-button",
            text: "Preview",
          )
        end
      end

      it "includes a 'Back to edit' button" do
        render_inline component

        expect(page).to have_css(COMPONENT_CLASS) do |component|
          expect(component).to have_css(
            "button.js-app-c-govspeak-editor__back-button",
            text: "Back to edit",
          )
        end
      end

      it "includes a preview element to be replaced by the Govspeak which JS will render into HTML" do
        render_inline component

        expect(page).to have_css(COMPONENT_CLASS) do |component|
          expect(component).to have_css(
            ".app-c-govspeak-editor__preview.js-locale-switcher-custom p",
            text: "Generating preview, please wait.",
          )
        end
      end
    end
  end

  context "when the field is NOT govspeak enabled" do
    before do
      allow(field).to receive(:govspeak_enabled?).and_return(false)
    end

    it_behaves_like "a field component", field_type: "textarea"

    it "does NOT display the 'Govspeak supported' hint" do
      render_inline component

      expect(page).to have_css(COMPONENT_CLASS) do |component|
        component.assert_no_selector(
          ".guidance",
          text: I18n.t("edition.hints.govspeak_enabled"),
        )
      end
    end

    it "does NOT include a 'Preview' button" do
      render_inline component

      expect(page).to have_css(COMPONENT_CLASS) do |component|
        component.assert_no_selector(
          "button.js-app-c-govspeak-editor__preview-button",
          text: "Preview",
        )
      end
    end

    it "does NOT include 'Back to edit' button" do
      render_inline component

      expect(page).to have_css(COMPONENT_CLASS) do |component|
        component.assert_no_selector(
          "button.js-app-c-govspeak-editor__back-button",
          text: "Back to edit",
        )
      end
    end

    it "does NOT include a preview element to be replaced by the rendered Govspeak" do
      render_inline component

      expect(page).to have_css(COMPONENT_CLASS) do |component|
        component.assert_no_selector(
          ".app-c-govspeak-editor__preview.js-locale-switcher-custom p",
          text: "Generating preview, please wait.",
        )
      end
    end
  end
end
