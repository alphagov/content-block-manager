RSpec.describe Edition::Show::DefaultBlockComponent, type: :component do
  let(:document) { build(:document, :pension) }
  let(:edition) { build(:edition, :pension, :published, document: document) }

  let(:embed_code) { "EMBED_CODE" }
  let(:embed_code_details) { "default block" }
  let(:default_block_output) { "DEFAULT_BLOCK_OUTPUT" }

  before do
    allow(document).to receive(:embed_code).and_return(embed_code)
    allow(edition).to receive(:render).with(embed_code).and_return(default_block_output)
  end

  context "when the edition is in the 'published' state" do
    before do
      edition.state = :published
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
        text: embed_code,
      )
    end

    it "includes 'data' attributes to initialise the CopyEmbedCode JS module" do
      data_attrs = [
        "[data-module='copy-embed-code']",
        "[data-embed-code='EMBED_CODE']",
        "[data-embed-code-details='default block']",
      ]

      expect(page).to have_css("div#{data_attrs.join}")
    end
  end

  (Edition.available_states - [:published]).each do |state|
    context "when the edition is in a non-published state (#{state})" do
      before do
        edition.state = state
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
          "[data-embed-code='EMBED_CODE']",
          "[data-embed-code-details='default block']",
        ]

        expect(page).to have_no_css("div#{data_attrs.join}")
      end
    end
  end
end
