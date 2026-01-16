RSpec.describe FactCheck::DefaultBlockComponent, type: :component do
  let(:document) { build(:document, :contact) }
  let(:current_edition) { build(:edition, :contact, document: document) }
  let(:published_edition) { build(:edition, :contact, document: document) }

  let(:before_block_output) { "<p>Hello</p>" }
  let(:after_block_output) { "<p>Goodbye</p>" }

  before do
    allow(current_edition).to receive(:render).and_return(before_block_output)
    allow(published_edition).to receive(:render).and_return(after_block_output)
  end

  it "renders the default block with the diff showing" do
    render_inline(
      FactCheck::DefaultBlockComponent.new(
        current_edition: current_edition,
        published_edition: published_edition,
      ),
    )

    expect(page).to have_css(
      ".govuk-summary-list__row .govuk-summary-list__value .govspeak.compare-editions",
    )
    expect(page).to have_css(
      "div.diff del strong",
      text: "Hell",
    )
    expect(page).to have_css(
      "div.diff ins strong",
      text: "G",
    )
    expect(page).to have_css(
      "div.diff ins strong",
      text: "odbye",
    )
  end
end
