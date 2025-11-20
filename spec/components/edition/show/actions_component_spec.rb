RSpec.describe Edition::Show::ActionsComponent, type: :component do
  let(:document) { FactoryBot.build(:document, :pension, id: 456) }
  let(:edition) { FactoryBot.build(:edition, :pension, document: document, id: 123) }

  describe "Button to transition to 'awaiting_2i' state" do
    context "when the edition is in the 'draft' state" do
      before do
        edition.state = :draft
        component = described_class.new(edition: edition)
        render_inline component
      end

      it "offers a button for the status transition" do
        expect(page).to have_css(
          ".actions form[action='/editions/123/edition_status_transitions'] button",
          text: "Send to 2i",
        )
      end
    end

    (Edition.available_states - [:draft]).each do |state|
      context "when the edition is in the '#{state}' state" do
        before do
          edition.state = state
          component = described_class.new(edition: edition)
          render_inline component
        end

        it "does NOT offer a button for the status transition" do
          expect(page).to have_no_button("Send to 2i")
        end
      end
    end
  end

  describe "link to create new draft edition" do
    Edition.available_states.each do |state|
      context "when the edition is in the '#{state}' state" do
        before do
          edition.state = state
          component = described_class.new(edition: edition)
          render_inline component
        end

        it "offers an 'Edit' link to create a new draft edition" do
          expect(page).to have_css(
            ".actions a.govuk-button--secondary[href='/456/editions/new']",
            text: "Edit pension",
          )
        end
      end
    end
  end
end
