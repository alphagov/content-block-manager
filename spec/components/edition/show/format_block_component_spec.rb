RSpec.describe Edition::Show::FormatBlockComponent, type: :component do
  let(:document) { build(:document, :time_period, content_id_alias: "tax-year") }
  let(:edition) { build(:edition, :time_period, :published, document: document) }

  let(:format) { "my_format" }
  let(:embed_code_for_format) { "{{embed:content_block_time_period:tax-year##{format}}}" }
  let(:embed_code_details) { "format block" }
  let(:format_block_output) { "FORMAT_BLOCK_OUTPUT" }

  before do
    allow(edition).to receive(:render).with(embed_code_for_format).and_return(format_block_output)
  end

  context "when Edition#show_embed_codes? is _true_" do
    before do
      allow(edition).to receive(:show_embed_codes?).and_return(true)
      render_inline(Edition::Show::FormatBlockComponent.new(edition: edition, format: format))
    end

    it "includes the format block output in a govspeak enabled element" do
      expect(page).to have_css(
        ".govspeak",
        text: format_block_output,
      )
    end

    it "includes the format's embed code in its own element" do
      expect(page).to have_css(
        ".govuk-summary-list__value .app-c-content-block-manager-format-block__embed_code",
        text: "{{embed:content_block_time_period:tax-year#my_format}}",
      )
    end

    it "includes 'data' attributes to initialise the CopyEmbedCode JS module" do
      data_attrs = [
        "[data-module='copy-embed-code']",
        "[data-embed-code='{{embed:content_block_time_period:tax-year#my_format}}']",
        "[data-embed-code-details='format block']",
      ]

      expect(page).to have_css("div#{data_attrs.join}")
    end
  end

  context "when Edition#show_embed_codes? is _false_" do
    before do
      allow(edition).to receive(:show_embed_codes?).and_return(false)
      render_inline(Edition::Show::FormatBlockComponent.new(edition: edition, format: format))
    end

    it "includes the format block output in a govspeak enabled element" do
      expect(page).to have_css(
        ".govspeak",
        text: format_block_output,
      )
    end

    it "does NOT include the format's embed code in its own element" do
      expect(page).not_to have_content(embed_code_for_format)
    end

    it "does NOT include 'data' attributes to initialise the CopyEmbedCode JS module" do
      data_attrs = [
        "[data-module='copy-embed-code']",
        "[data-embed-code='{{embed:content_block_time_period:tax-year#my_format}}']",
        "[data-embed-code-details='format block']",
      ]

      expect(page).to have_no_css("div#{data_attrs.join}")
    end
  end
end
