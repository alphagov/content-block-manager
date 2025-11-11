RSpec.describe Shared::TransitionButtonComponent, type: :component do
  let(:edition) { build_stubbed :edition, id: 123 }
  let(:component) { described_class.new(edition: edition, transition: transition) }

  context "when the given transition is 'ready_for_2i'" do
    let(:transition) { "ready_for_2i" }

    it "generates a form to submit a new 'Status Transition'" do
      render_inline component

      expect(page).to have_css(
        "form[action='/editions/123/edition_status_transitions']",
      )
    end

    it "uses 'ready_for_2i' as the hidden _transition_ field" do
      render_inline component

      expect(page).to have_css(
        "form input[type='hidden'][value='ready_for_2i'][name='transition']",
        visible: false,
      )
    end

    it "shows the 'Send to 2i' call to action" do
      render_inline component

      expect(page).to have_css(
        "form button[type='submit']",
        text: "Send to 2i",
      )
    end
  end

  context "when the given transition is something else" do
    let(:transition) { "unsupported_transition" }

    it "raises an UnknownTransitionError" do
      expect { render_inline component }.to raise_error(
        Shared::TransitionButtonComponent::UnknownTransitionError,
        "Transition event 'unsupported_transition' is not recognised'",
      )
    end
  end
end
