RSpec.describe Edition::Show::ActionsComponent, type: :component do
  let(:document) { FactoryBot.build(:document, :pension, id: 456) }
  let(:edition) { FactoryBot.build(:edition, :pension, document: document, id: 123) }

  describe "Button to transition to 'awaiting_review' state" do
    context "when the edition is in the 'draft' state" do
      before do
        edition.state = :draft
      end

      context "and the draft workflow has been completed" do
        before do
          edition.workflow_completed_at = 1.minute.ago
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

      context "and the draft workflow has NOT been completed" do
        before do
          edition.workflow_completed_at = nil
          component = described_class.new(edition: edition)
          render_inline component
        end

        it "does NOT offer a button for the status transition" do
          expect(page).to have_no_button("Send to 2i")
        end

        it "offers a link to 'Complete draft' via workflow review step" do
          expect(page).to have_css(
            ".actions a[href='/editions/123/workflow/review']",
            text: "Complete draft",
          )
        end
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

  describe "Button to transition to 'awaiting_factcheck' state" do
    context "when the edition is in the 'awaiting_review' state" do
      before do
        edition.state = :awaiting_review
        component = described_class.new(edition: edition)
        render_inline component
      end

      it "offers a button to record the Review outcome" do
        expect(page).to have_css(
          ".actions a[href='/editions/123/review_outcomes/new']",
          text: "Send to factcheck",
        )
      end
    end

    (Edition.available_states - [:awaiting_review]).each do |state|
      context "when the edition is in the '#{state}' state" do
        before do
          edition.state = state
          component = described_class.new(edition: edition)
          render_inline component
        end

        it "does NOT offer a button to record the Review outcome" do
          expect(page).to have_no_link("Send to Factcheck")
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

  describe "link to latest published edition" do
    context "when the edition is in the 'published' state" do
      before do
        edition.state = :published
        component = described_class.new(edition: edition)
        render_inline component
      end

      it "does NOT offer the link to the published edition" do
        expect(page).to have_no_link("Go to published edition")
      end
    end

    (Edition.available_states - [:published]).each do |state|
      context "when the edition is in the '#{state}' state" do
        before do
          edition.state = state
        end

        context "if a published edition exists" do
          before do
            allow(document).to receive(:has_published_edition?).and_return(true)
            component = described_class.new(edition: edition)
            render_inline component
          end

          it "offers the link to the published edition" do
            expect(page).to have_link(
              "Go to published edition",
              href: "/456/published_edition",
            )
          end
        end

        context "if a published edition does NOT exist" do
          before do
            allow(document).to receive(:has_published_edition?).and_return(false)
            component = described_class.new(edition: edition)
            render_inline component
          end

          it "does NOT offer a link to the published edition" do
            expect(page).to have_no_link("Go to published edition")
          end
        end
      end
    end
  end

  describe "link to delete the edition" do
    Edition.in_progress_states.each do |state|
      it "should appear for 'in-progress' editions" do
        edition.state = state
        component = described_class.new(edition: edition)
        render_inline component

        expect(page).to have_link("Delete", href: "/editions/123/delete"),
                        "Expected to see 'Delete' link when in '#{state}' state"
      end
    end

    Edition.finalised_states.each do |state|
      it "should NOT appear for editions which can't be deleted" do
        edition.state = state
        component = described_class.new(edition: edition)
        render_inline component

        expect(page).not_to have_link("Delete"),
                            "Expected NOT to see 'Delete' link when in '#{state}' state"
      end
    end
  end
end
