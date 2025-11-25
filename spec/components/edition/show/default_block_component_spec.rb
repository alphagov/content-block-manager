RSpec.describe Edition::Show::DefaultBlockComponent, type: :component do
  let(:document) { build(:document, :pension) }
  let(:edition) { build(:edition, :pension, document: document) }

  let(:embed_code) { "EMBED_CODE" }
  let(:embed_code_details) { "default block" }
  let(:default_block_output) { "DEFAULT_BLOCK_OUTPUT" }

  before do
    allow(document).to receive(:embed_code).and_return(embed_code)
    allow(edition).to receive(:render).with(embed_code).and_return(default_block_output)
  end

  it "renders the default block" do
    render_inline(
      Edition::Show::DefaultBlockComponent.new(edition: edition),
    )

    expect(page).to have_css(
      ".govuk-summary-list__row[data-module=\"copy-embed-code\"][data-embed-code=\"#{embed_code}\"] .govuk-summary-list__value .govspeak",
      text: default_block_output,
    )

    expect(page).to have_css(
      ".govuk-summary-list__value .app-c-content-block-manager-default-block__embed_code",
      text: embed_code,
    )
  end

  it "includes detail on embed code in a data attr for use in visually hidden link info" do
    render_inline(
      Edition::Show::DefaultBlockComponent.new(edition: edition),
    )

    expect(page).to have_css(
      ".govuk-summary-list__row[data-embed-code-details='#{embed_code_details}']",
      text: default_block_output,
    )
  end
end
