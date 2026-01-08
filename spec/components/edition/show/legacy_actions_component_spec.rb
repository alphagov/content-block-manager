RSpec.describe Edition::Show::LegacyActionsComponent, type: :component do
  let(:document) { FactoryBot.build(:document, :pension, id: 456) }
  let(:edition) { FactoryBot.build(:edition, :pension, document: document, id: 123) }

  let(:latest_edition_id) { 123 }
  let(:newer_draft_edition_id) { 789 }

  before do
    allow(document).to receive(:most_recent_edition).and_return(double(:edition, id: newer_draft_edition_id))
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
          end

          context "when the edition being viewed is not the latest edition" do
            before do
              component = described_class.new(edition: edition)
              render_inline component
            end

            it "offers an 'Edit latest edition' link to return to editing the draft edition" do
              expect(page).to have_css(
                ".actions a.govuk-button[href='/editions/789/workflow/edit_draft']",
                text: "Edit latest edition",
              )
            end
          end

          context "when the edition being viewed **is** the latest edition" do
            before do
              allow(document).to receive(:most_recent_edition).and_return(double(:edition, id: latest_edition_id))
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
              ".actions a.govuk-button--secondary[href='/editions/123/workflow/edit_draft']",
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
          ".actions a.govuk-button[href='/editions/123/workflow/edit_draft']",
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
              ".actions a.govuk-button[href='/editions/123/workflow/edit_draft']",
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

  describe "link to go back to the latest edition" do
    context "when the edition being viewed is published" do
      let(:latest_edition_id) { 123 }
      let(:newer_draft_edition_id) { 124 }

      before do
        edition.state = :published
      end

      context "and the edition being viewed is not the latest edition" do
        before do
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
