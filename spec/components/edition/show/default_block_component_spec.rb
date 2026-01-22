RSpec.describe Edition::Show::DefaultBlockComponent, type: :component do
  let(:document) { build(:document, :pension) }
  let(:edition) { build(:edition, :pension, :published, document: document) }

  let(:embed_code) { "{{embed:content_block_contact:test-block}}" }
  let(:embed_code_details) { "default block" }
  let(:default_block_output) { "DEFAULT_BLOCK_OUTPUT" }

  before do
    allow(document).to receive(:embed_code).and_return(embed_code)
    allow(edition).to receive(:render).with(embed_code).and_return(default_block_output)
  end

  context "when Edition#show_embed_codes? is _true_" do
    before do
      allow(edition).to receive(:show_embed_codes?).and_return(true)
      render_inline(Edition::Show::DefaultBlockComponent.new(edition: edition))
    end

    it "includes the default block output in a govspeak enabled element" do
      expect(page).to have_css(
        ".govspeak",
        text: default_block_output,
      )
    end

    it "includes the embed code in its own element" do
      expect(page).to have_css(
        ".govuk-summary-list__value .app-c-content-block-manager-default-block__embed_code",
        text: "{{embed:content_block_contact:test-block}}",
      )
    end

    it "includes 'data' attributes to initialise the CopyEmbedCode JS module" do
      data_attrs = [
        "[data-module='copy-embed-code']",
        "[data-embed-code='{{embed:content_block_contact:test-block}}']",
        "[data-embed-code-details='default block']",
      ]

      expect(page).to have_css("div#{data_attrs.join}")
    end
  end

  context "when Edition#show_embed_codes? is _false_" do
    before do
      allow(edition).to receive(:show_embed_codes?).and_return(false)
      render_inline(Edition::Show::DefaultBlockComponent.new(edition: edition))
    end

    it "includes the default block output in a govspeak enabled element" do
      expect(page).to have_css(
        ".govspeak",
        text: default_block_output,
      )
    end

    it "does NOT include the embed code in its own element" do
      expect(page).not_to have_content(embed_code)
    end

    it "does NOT include 'data' attributes to initialise the CopyEmbedCode JS module" do
      data_attrs = [
        "[data-module='copy-embed-code']",
        "[data-embed-code='{{embed:content_block_contact:test-block}}']",
        "[data-embed-code-details='default block']",
      ]

      expect(page).to have_no_css("div#{data_attrs.join}")
    end
  end
end
