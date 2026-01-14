RSpec.describe Shared::TransitionButtonComponent, type: :component do
  let(:edition) { build_stubbed :edition, id: 123 }
  let(:component) { described_class.new(edition: edition, transition: transition) }

  context "when the edition is performing any valid transition" do
    Edition.new.available_transitions.each do |available_transition|
      context "for transition #{available_transition}" do
        let(:transition) { available_transition }
        let(:component) { described_class.new(edition: edition, transition: transition) }

        it "generates a form to submit a new 'Status Transition'" do
          render_inline component
          expect(page).to have_css(
            "form[action='/editions/123/edition_status_transitions']",
          )
        end

        it "uses '#{available_transition}' as the hidden _transition_ field" do
          render_inline component

          expect(page).to have_css(
            "form input[type='hidden'][value='#{transition}'][name='transition']",
            visible: false,
          )
        end

        it "uses '#{available_transition}' as the hidden _transition_ field" do
          render_inline component

          expect(page).to have_css(
            "form input[type='hidden'][value='#{transition}'][name='transition']",
            visible: false,
          )
        end
      end
    end
  end

  context "when the given transition is 'ready_for_review'" do
    let(:transition) { "ready_for_review" }
    let(:edition) { build_stubbed :edition, :draft_complete, id: 123 }
    let(:component) { described_class.new(edition: edition, transition: transition) }

    it "shows the 'Ready for 2i' call to action" do
      render_inline component
      expect(page).to have_css("form button[type='submit']", text: "Ready for 2i")
    end
  end

  context "when the given transition is 'schedule'" do
    let(:transition) { "schedule" }
    let(:edition) { build_stubbed :edition, :awaiting_factcheck }

    it "shows the 'Schedule' call to action" do
      render_inline component
      expect(page).to have_css("form button[type='submit']", text: "Schedule")
    end
  end

  context "when the given transition is 'publish'" do
    let(:transition) { "publish" }

    it "shows the 'Publish' call to action" do
      render_inline component
      expect(page).to have_css("form button[type='submit']", text: "Publish")
    end
  end

  context "when the given transition is 'delete'" do
    let(:transition) { "delete" }

    it "shows the 'Delete' call to action" do
      render_inline component
      expect(page).to have_css("form button[type='submit']", text: "Delete")
    end
  end

  context "when the given transition is 'supersede'" do
    let(:edition) { build_stubbed :edition, :scheduled }
    let(:transition) { "supersede" }

    it "shows the 'Supersede' call to action" do
      render_inline component
      expect(page).to have_css("form button[type='submit']", text: "Supersede")
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
