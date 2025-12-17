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
    context "for 'in-progress' states" do
      Edition.in_progress_states.each do |state|
        context "when the edition is in the '#{state}' state" do
          before do
            edition.state = state
            component = described_class.new(edition: edition)
            render_inline component
          end

          it "does NOT offer an 'Edit {block type}' link to create a new draft edition" do
            expect(page).to have_no_css(
              ".actions a.govuk-button[href='/456/editions/new']",
              text: "Edit pension",
            )
          end
        end
      end
    end

    context "for 'finalised' states" do
      Edition.finalised_states.each do |state|
        context "when the edition is in the '#{state}' state" do
          before do
            edition.state = state
            component = described_class.new(edition: edition)
            render_inline component
          end

          it "offers an 'Edit {block type}' link to create a new draft edition" do
            expect(page).to have_css(
              ".actions a.govuk-button[href='/456/editions/new']",
              text: "Edit pension",
            )
          end
        end
      end
    end
  end

  describe "link to 'Edit draft'" do
    before { allow(edition).to receive(:completed?).and_return(true) }

    context "for 'in-progress' states" do
      Edition.in_progress_states.each do |state|
        context "when the edition is in the '#{state}' state" do
          before do
            edition.state = state
            component = described_class.new(edition: edition)
            render_inline component
          end

          it "offers a secondary 'Edit draft' link to edit the current draft" do
            expect(page).to have_css(
              ".actions a.govuk-button--secondary[href='/editions/123/workflow/review']",
              text: "Edit draft",
            )
          end
        end
      end
    end

    context "when the edition is in the 'draft' state but not completed" do
      before do
        allow(edition).to receive(:completed?).and_return(false)
        edition.state = "draft"
        component = described_class.new(edition: edition)
        render_inline component
      end

      it "offers a 'Complete draft' link to edit the current draft" do
        expect(page).to have_css(
          ".actions a.govuk-button[href='/editions/123/workflow/review']",
          text: "Complete draft",
        )
      end
    end

    context "for 'finalised' states" do
      Edition.finalised_states.each do |state|
        context "when the edition is in the '#{state}' state" do
          before do
            edition.state = state
            component = described_class.new(edition: edition)
            render_inline component
          end

          it "does NOT offer an 'Edit draft' link to edit a current draft" do
            expect(page).to have_no_css(
              ".actions a.govuk-button[href='/editions/123/workflow/review']",
              text: "Edit draft",
            )
          end
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

  describe "button to publish or schedule the edition via the factcheck outcome page" do
    context "when the edition is in an awaiting_factcheck state" do
      before do
        edition.state = :awaiting_factcheck
      end

      context "when the edition doesn't have a scheduled publication date" do
        before do
          edition.scheduled_publication = nil
          component = described_class.new(edition: edition)
          render_inline component
        end

        it "offers a button to publish the edition" do
          expect(page).to have_link("Publish block",
                                    href: "/editions/123/factcheck_outcomes/new")
        end
      end

      context "when the edition has a scheduled publication date" do
        before do
          edition.scheduled_publication = Time.zone.now + 1.day
          component = described_class.new(edition: edition)
          render_inline component
        end

        it "offers a button to schedule the edition" do
          expect(page).to have_link("Schedule block",
                                    href: "/editions/123/factcheck_outcomes/new")
        end
      end
    end

    context "when the edition is NOT in an awaiting_factcheck state" do
      (Edition.available_states - %i[awaiting_factcheck]).each do |state|
        before do
          edition.state = state
          component = described_class.new(edition: edition)
          render_inline component
        end

        it "does NOT offer a button to publish or schedule the edition (#{state} state)" do
          aggregate_failures "checking for publish/schedule button" do
            expect(page).to have_no_link("Publish block")
            expect(page).to have_no_link("Schedule block")
          end
        end
      end
    end
  end

  describe "link to go back to the latest edition" do
    context "when the edition being viewed is published" do
      let(:latest_edition_id) { 123 }
      let(:newer_draft_edition_id) { 124 }

      before do
        edition.state = :published
      end

      context "and the edition being viewed is not the latest edition" do
        before do
          allow(document).to receive(:most_recent_edition).and_return(double(:edition, id: newer_draft_edition_id))
          component = described_class.new(edition: edition)
          render_inline component
        end

        it "shows the link to return to the latest edition" do
          expect(page).to have_link("Return to latest edition", href: "/456")
        end
      end

      context "and the edition being viewed is the latest edition" do
        before do
          allow(document).to receive(:most_recent_edition).and_return(double(:edition, id: latest_edition_id))
          component = described_class.new(edition: edition)
          render_inline component
        end

        it "shows the link to return to the latest edition" do
          expect(page).to have_no_link("Return to latest edition", href: "/456")
        end
      end
    end

    (Edition.available_states - [:published]).each do |state|
      context "when the edition being viewed is not published (#{state})" do
        before do
          edition.state = state
          component = described_class.new(edition: edition)
          render_inline component
        end

        it "does not show the link to return to the latest edition" do
          expect(page).to have_no_link("Return to latest edition")
        end
      end
    end
  end
end
