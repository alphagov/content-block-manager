RSpec.describe Editions::ReviewOutcomesController, type: :controller do
  let(:document) { Document.new(id: 456) }
  let(:edition) { instance_double(Edition, id: 123, document: document) }

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
            expected_success_message = "Edition has been moved into state 'Awaiting factcheck'"
            expect(flash.notice).to eq(expected_success_message)
          end
        end
      end

      context "when the transition fails" do
        context "and the Review outcome was missing" do
          it "redirects to the 'new review_outcome' form"
          it "includes an error message saying that the Review outcome is required"
        end
        context "and the error was something else (e.g. unexpected state)" do
          it "redirects to the document path"
          it "includes an error message with the transition error details"
        end
      end
    end

    context "when the form returned is NOT valid" do
      it "re-renders the 'new' template to allow the errors to be corrected"
    end
  end
end
