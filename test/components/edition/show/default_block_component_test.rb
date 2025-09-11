require "test_helper"

class Edition::Show::DefaultBlockComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:edition) { build(:edition, :pension) }
  let(:document) { build(:document, :pension) }

  let(:embed_code) { "EMBED_CODE" }
  let(:default_block_output) { "DEFAULT_BLOCK_OUTPUT" }

  before do
    document.stubs(:latest_edition).returns(edition)
    document.stubs(:embed_code).returns(embed_code)
    edition.stubs(:render).with(embed_code).returns(default_block_output)
  end

  it "renders the default block" do
    render_inline(
      Document::Show::DefaultBlockComponent.new(document:),
    )

    assert_selector ".govuk-summary-list__row[data-module=\"copy-embed-code\"][data-embed-code=\"#{embed_code}\"] .govuk-summary-list__value .govspeak", text: default_block_output
    assert_selector ".govuk-summary-list__value .app-c-content-block-manager-default-block__embed_code", text: embed_code
  end
end
