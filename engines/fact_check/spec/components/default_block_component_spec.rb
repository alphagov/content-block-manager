RSpec.describe FactCheck::DefaultBlockComponent, type: :component do
  let(:document) { build(:document, :contact) }
  let(:published_block) { build(:content_block) }
  let(:content_block) { build(:content_block) }

  let(:before_block_output) { "<p>Hello</p>" }
  let(:after_block_output) { "<p>Goodbye</p>" }

  before do
    allow(content_block).to receive(:published_block).and_return(published_block)

    allow(published_block).to receive(:render).and_return(before_block_output)
    allow(content_block).to receive(:render).and_return(after_block_output)
  end

  it "renders the default block with the diff showing" do
    render_inline(
      FactCheck::DefaultBlockComponent.new(block: content_block),
    )

    expect(page).to have_css(
      ".govuk-summary-list__row .govuk-summary-list__value .govspeak.compare-editions",
    )
    expect(page).to have_css(
      "div.diff del strong",
      text: "Hell",
    )
    expect(page).to have_css(".diff", text: "Hello")

    expect(page).to have_css(
      "div.diff ins strong",
      text: "G",
    )
    expect(page).to have_css(
      "div.diff ins strong",
      text: "odbye",
    )
    expect(page).to have_css(".diff", text: "Goodbye")
  end
end
