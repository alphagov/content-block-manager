RSpec.describe Editions::ReviewOutcomesController, type: :controller do
  let(:document) { Document.new(id: 456) }
  let(:edition) { Edition.new(id: 123, document: document) }

  before do
    allow(Edition).to receive(:find).and_return(edition)
  end

  describe "GET to :new" do
    before do
      get :new, params: { id: 123 }
    end

    it "sets the @edition variable to the given edition" do
      expect(Edition).to have_received(:find).with("123")
      expect(assigns(:edition)).to eq(edition)
    end

    it "renders the editions/review_outcomes/new template" do
      expect(response).to have_rendered("editions/review_outcomes/new")
    end
  end

  describe "POST to :create" do
    let(:time_now) { Time.current }
    let(:current_user) { instance_double(User, id: 987) }

    before do
      allow(Time).to receive(:current).and_return(time_now)
      allow(Current).to receive(:user).and_return(current_user)
      allow(edition).to receive(:ready_for_factcheck!)
    end

    context "when the form returned is valid" do
      before do
        allow(edition).to receive(:update).and_return(true)
      end

      describe "saving othe Review outcome details" do
        context "when the editor has indicated that the Review was skipped" do
          before do
            post :create, params: {
              id: 123,
              "review_outcome" => { "review_performed" => false },
            }
          end

          it "saves the Review outcome details" do
            expect(edition).to have_received(:update).with(
              "review_skipped" => true,
              "review_outcome_recorded_at" => time_now,
              "review_outcome_recorded_by" => 987,
            )
          end
        end

        context "when the editor has indicated that the Review was performed" do
          before do
            post :create, params: {
              id: 123,
              "review_outcome" => { "review_performed" => true },
            }
          end

          it "saves the Review outcome details" do
            expect(edition).to have_received(:update).with(
              "review_skipped" => false,
              "review_outcome_recorded_at" => time_now,
              "review_outcome_recorded_by" => 987,
            )
          end

          it "transitions the edition using 'ready_for_factcheck!' state" do
            expect(edition).to have_received(:ready_for_factcheck!)
          end

          it "redirects to the documents_path to display the most recent edition" do
            expect(response).to redirect_to("/456")
          end

          it "shows a success message" do
            expected_success_message = I18n.t("edition.states.transition_message.awaiting_factcheck")
            expect(flash.notice).to eq(expected_success_message)
          end
        end
      end

      context "when the transition fails" do
        context "and the Review outcome was missing" do
          before do
            allow(edition).to receive(:ready_for_factcheck!).and_raise(
              Edition::Workflow::ReviewOutcomeMissingError,
              "Informative error message",
            )

            post :create, params: {
              id: 123,
              "review_outcome" => { "review_performed" => true },
            }
          end

          it "handles the error and redirects to the 'new review_outcome' form" do
            expect(response).to redirect_to("/editions/123/review_outcomes/new")
          end

          it "includes an error message saying that the Review outcome is required" do
            expect(flash.alert).to eq("Informative error message")
          end
        end

        context "and the error was something else (e.g. unexpected state)" do
          let(:error_message) do
            "Can't fire event `ready_for_factcheck` in current state `draft` " \
              "for `Edition` with ID 123  (Transitions::InvalidTransition)"
          end

          before do
            allow(edition).to receive(:ready_for_factcheck!).and_raise(
              Transitions::InvalidTransition,
              error_message,
            )

            post :create, params: {
              id: 123,
              "review_outcome" => { "review_performed" => true },
            }
          end

          it "redirects to the document path" do
            expect(response).to redirect_to("/456")
          end

          it "includes an error message with the transition error details" do
            expect(flash.alert).to eq(
              "Error: we can not change the status of this edition. #{error_message}",
            )
          end
        end
      end
    end

    context "when the form returned is NOT valid" do
      before do
        post :create, params: {
          id: 123,
          "review_outcome" => {},
        }
      end

      it "re-renders the 'new' template to allow the errors to be corrected" do
        expect(response).to have_rendered(:new)
      end

      it "sets an error message" do
        expect(flash.alert).to eq("Indicate whether the 2i Review process has been performed or not")
      end
    end
  end
end
