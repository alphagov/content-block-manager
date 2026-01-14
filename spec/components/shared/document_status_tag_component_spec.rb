RSpec.describe Shared::DocumentStatusTagComponent, type: :component do
  let(:edition) { instance_double(Edition, state: :draft) }

  let(:component) { described_class.new(edition: edition) }

  before do
    allow(I18n).to receive(:t).and_return("Translated state")
    render_inline(component)
  end

  it "sets a helpful 'title' attribute" do
    expect(page).to have_css(".govuk-tag[title='Status: Translated state']")
  end

  it "sets  an aria label for screenreaders" do
    expect(page).to have_css(".govuk-tag[aria-label='Status: Translated state']")
  end

  it "displays a translated version of the given edition's state" do
    within ".govuk-tag" do
      expect(page).to have_content("Translated state")
    end
  end

  describe "#colour" do
    expected_colours = {
      draft: "yellow",
      draft_complete: "yellow",
      awaiting_review: "turquoise",
      awaiting_factcheck: "pink",
      scheduled: "light-blue",
      published: "green",
      superseded: "orange",
      deleted: "red",
    }

    Edition.new.available_states.each do |state|
      it "returns '#{expected_colours.fetch(state)}' for state '#{state}'" do
        allow(edition).to receive(:state).and_return(state)

        expect(component.colour).to eq(expected_colours.fetch(state))
      end
    end

    context "if there's no colour mapped for the given state" do
      before { allow(edition).to receive(:state).and_return(:unknown_state) }

      it "raises an UnexpectedStatusError" do
        expect { component.colour }.to raise_error(
          Shared::DocumentStatusTagComponent::UnexpectedStatusError,
          "No colour mapped for state 'unknown_state'",
        )
      end
    end
  end

  describe "applies Design System colour styling successfully to govuk-tag" do
    expected_colours = {
      draft: "yellow",
      draft_complete: "yellow",
      awaiting_review: "turquoise",
      awaiting_factcheck: "pink",
      scheduled: "light-blue",
      published: "green",
      superseded: "orange",
      deleted: "red",
    }

    Edition.new.available_states.each do |state|
      it "sets the tag--{colour} '#{expected_colours.fetch(state)}' for state '#{state}'" do
        allow(edition).to receive(:state).and_return(state)

        render_inline(component)

        expect(page).to have_css(".govuk-tag--#{expected_colours.fetch(state)}")
      end
    end
  end
end
