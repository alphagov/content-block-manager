RSpec.describe Edition::Workflow::ReviewActionsComponent, type: :component do
  let(:edition) { build(:edition, :pension, :draft, id: 123) }
  let(:document) { edition.document }
  let(:component) { described_class.new(edition: edition) }

  context "when the pre-release features are enabled" do
    before do
      allow_any_instance_of(ApplicationHelper).to receive(:pre_release_features?).and_return(true)
    end

    describe "workflow completion submit button" do
      describe "'Send to review' action" do
        context "when the edition is in the 'draft' state" do
          before { edition.state = :draft }

          it "offers a 'Send to review' workflow completion action" do
            render_inline(component)

            expect(page).to have_css(
              "button.govuk-button[name='save_action'][value='send_to_review']",
              text: "Send to 2i",
            )
          end
        end

        (Edition.available_states - [:draft]).each do |state|
          context "when the edition is in the '#{state} state" do
            before { edition.state = state }

            it "does not offer the 'Send to review' option" do
              render_inline(component)

              expect(page).to have_no_css(
                "button[name='save_action'][value='send_to_review']",
              )
            end
          end
        end
      end

      describe "Save (as) draft button" do
        context "when the edition is in the 'draft' state" do
          it "offers a 'Save as draft' workflow completion secondary action" do
            render_inline(component)

            expect(page).to have_css(
              "button.govuk-button--secondary[name='save_action'][value='save_as_draft']",
              text: "Save as draft",
            )
          end
        end

        %i[awaiting_review awaiting_factcheck scheduled].each do |state|
          context "when the edition is in the '#{state}' state" do
            before { edition.state = state }

            it "offers a 'Save draft' workflow completion primary action" do
              render_inline(component)

              aggregate_failures do
                expect(page).to have_css(
                  "button.govuk-button[name='save_action'][value='save_as_draft']",
                  text: "Save draft",
                )
                expect(page).to have_no_css(
                  "button.govuk-button--secondary[name='save_action'][value='save_as_draft']",
                )
              end
            end
          end
        end
      end
    end

    describe "cancel button" do
      context "when more than one edition exists" do
        before do
          2.times { create(:edition, document: document) }
          expect(edition.document.editions.count).to be > 1
        end

        it "is a link to the cancel workflow index path" do
          render_inline(component)

          expect(page).to have_css(
            "a.govuk-button--secondary[href='/editions/123/workflow/cancel']",
            text: "Cancel",
          )
        end
      end

      context "when there's only one edition" do
        before do
          create(:edition, document: document)
          expect(edition.document.editions.count).to eq(1)
        end

        it "has a link to confirm deletion of the edition and the document" do
          render_inline(component)

          expect(page).to have_css(
            "a.govuk-button--secondary[href='/editions/123/workflow/cancel']",
            text: "Cancel",
          )
        end
      end
    end
  end

  context "when the pre-release features are NOT enabled" do
    before do
      allow_any_instance_of(ApplicationHelper).to receive(:pre_release_features?).and_return(false)
    end

    describe "submit button" do
      describe "text" do
        context "when publication has been scheduled" do
          before { edition.scheduled_publication = 1.week.from_now }

          it "names the button 'Schedule'" do
            render_inline(component)

            expect(page).to have_css("button[name='save_action']", text: "Schedule")
          end
        end

        context "when the block is new" do
          before do
            allow(document).to receive(:is_new_block?).and_return(true)
          end

          it "names the button 'Create'" do
            render_inline(component)

            expect(page).to have_css("button[name='save_action']", text: "Create")
          end
        end

        context "when the block is NOT new" do
          before do
            allow(document).to receive(:is_new_block?).and_return(false)
          end

          it "names the button 'Publish'" do
            render_inline(component)

            expect(page).to have_css("button[name='save_action']", text: "Publish")
          end
        end
      end

      describe "action" do
        context "when publication has been scheduled" do
          before { edition.scheduled_publication = 1.week.from_now }

          it "provides the 'schedule' action" do
            render_inline(component)

            expect(page).to have_css("button[name='save_action'][value='schedule']")
          end
        end

        context "when publication has NOT been scheduled" do
          before { edition.scheduled_publication = nil }

          it "provides the 'publish' action" do
            render_inline(component)

            expect(page).to have_css("button[name='save_action'][value='publish']")
          end
        end
      end
    end

    describe "cancel button" do
      context "when more than one edition exists" do
        before do
          2.times { create(:edition, document: document) }
          expect(edition.document.editions.count).to be > 1
        end

        it "is a link to the cancel workflow index path" do
          render_inline(component)

          expect(page).to have_css(
            "a.govuk-button--secondary[href='/editions/123/workflow/cancel']",
            text: "Cancel",
          )
        end
      end

      context "when there's only one edition" do
        before do
          create(:edition, document: document)
          expect(edition.document.editions.count).to eq(1)
        end

        it "has a link to confirm deletion of the edition and the document" do
          render_inline(component)

          expect(page).to have_css(
            "a.govuk-button--secondary[href='/editions/123/workflow/cancel']",
            text: "Cancel",
          )
        end
      end
    end
  end
end
