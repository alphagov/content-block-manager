RSpec.describe Editions::ReviewOutcomesController, type: :controller do
  let(:document) { create(:document, :pension, id: 456) }
  let(:edition) { create(:edition, :pension, id: 123, document: document) }

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
    let(:current_user) { instance_double(User, id: 1) }

    before do
      allow(Time).to receive(:current).and_return(time_now)
      allow(Current).to receive(:user).and_return(current_user)
    end

    context "when the form returned is valid" do
      before do
        allow(edition).to receive(:create_review_outcome!)
      end

      describe "saving the Review outcome details" do
        context "when the editor has indicated that the Review was skipped" do
          before do
            post :create, params: {
              id: 123,
              "review_outcome" => { "review_performed" => false },
            }
          end

          it "saves the Review outcome details" do
            expect(edition).to have_received(:create_review_outcome!).with(
              "skipped" => true,
              "creator" => current_user,
            )
          end

          it "redirects to the document path" do
            expect(response).to redirect_to("/456")
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
            expect(edition).to have_received(:create_review_outcome!).with(
              "skipped" => false,
              "creator" => current_user,
            )
          end
        end
      end

      describe "redirecting to the appropriate next step" do
        before do
          post :create, params: {
            id: 123,
            "review_outcome" => { "review_performed" => true },
          }
        end

        it "should redirect the user to the identify_performer step of the fact check process" do
          expect(response).to redirect_to("/editions/123/review_outcomes/identify_performer")
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
        expect(flash.alert).to eq("Indicate whether the 2i review process has been performed or not")
      end
    end
  end

  describe "GET to :identify_performer" do
    before do
      get :identify_performer, params: { id: 123 }
    end

    it "sets the @edition variable to the given edition" do
      expect(Edition).to have_received(:find).with("123")
      expect(assigns(:edition)).to eq(edition)
    end

    it "renders the editions/review_outcomes/identify_performer template" do
      expect(response).to have_rendered("editions/review_outcomes/identify_performer")
    end
  end

  describe "PUT to :update" do
    let(:time_now) { Time.current }
    let(:current_user) { instance_double(User, id: 987) }
    let(:review_outcome) { spy(ReviewOutcome) }

    before do
      allow(Time).to receive(:current).and_return(time_now)
      allow(Current).to receive(:user).and_return(current_user)
      allow(edition).to receive(:update)
      allow(edition).to receive(:ready_for_factcheck!)
      allow(edition).to receive(:review_outcome).and_return(review_outcome)
    end

    context "when the request is valid" do
      before do
        put :update, params: {
          id: 123,
          "review_outcome" => { "review_performer" => "Alice" },
        }
      end

      it "should update the edition with the 2i reviewer" do
        expect(edition.review_outcome).to have_received(:update!).with({ "performer" => "Alice" })
      end
    end

    context "when the performer field is missing" do
      before do
        put :update, params: {
          id: 123,
          "review_outcome" => {},
        }
        allow(edition).to receive(:ready_for_factcheck!)
      end

      it "redirects to the same page to prevent the user progressing" do
        expect(response).to redirect_to("/editions/123/review_outcomes/identify_performer")
      end

      it "shows an error message" do
        expected_message = I18n.t("edition.outcomes.errors.missing_performer.review")
        expect(flash.alert).to eq(expected_message)
      end

      it "should not transition to the next state" do
        expect(edition).not_to have_received(:ready_for_factcheck!)
      end
    end

    context "when the performer field is blank" do
      before do
        put :update, params: {
          id: 123,
          "review_outcome" => { "review_performer" => "" },
        }
        allow(edition).to receive(:ready_for_factcheck!)
      end

      it "redirects to the same page to prevent the user progressing" do
        expect(response).to redirect_to("/editions/123/review_outcomes/identify_performer")
      end

      it "shows an error message" do
        expected_message = I18n.t("edition.outcomes.errors.missing_performer.review")
        expect(flash.alert).to eq(expected_message)
      end

      it "should not transition to the next state" do
        expect(edition).not_to have_received(:ready_for_factcheck!)
      end
    end

    context "when updating the outcome with the performer" do
      let(:edition) { Edition.new(id: 123, document: document) }
      before do
        put :update, params: {
          id: 123,
          "review_outcome" => { "review_performer" => "Alice" },
        }
      end

      it "transitions the edition using the 'ready_for_factcheck!' transition" do
        expect(edition).to have_received(:ready_for_factcheck!)
      end

      it "redirects to the documents_path to display the most recent edition" do
        expect(response).to redirect_to("/456")
      end

      it "shows a success message" do
        expected_success_message = Edition::StateTransitionMessage.new(
          edition: edition,
          state: :awaiting_factcheck,
        ).to_s
        expect(flash[:success]).to eq(expected_success_message)
      end

      it "shows an important notice directing user to share the link" do
        expect(flash[:notice]).to eq(I18n.t("edition.states.important_notice.awaiting_factcheck"))
      end
    end

    describe "when the transition fails" do
      let(:error_message) do
        "Something bad has happened!"
      end
      let(:error_report) { instance_double(Edition::StateTransitionErrorReport, call: nil) }
      let(:error) { Transitions::InvalidTransition.new(error_message) }

      before do
        allow(edition).to receive(:ready_for_factcheck!).and_raise(error)

        allow(Edition::StateTransitionErrorReport).to receive(:new).and_return(error_report)

        put :update, params: {
          id: 123,
          "review_outcome" => { "review_performer" => "Alice" },
        }
      end

      it "redirects to the document path" do
        expect(response).to redirect_to("/456")
      end

      it "includes an error message" do
        expect(flash.alert).to eq(
          "Error: it was not possible to perform that action. The error has been logged.",
        )
      end

      it "records the error details using StateTransitionErrorReport to facilitate remediation" do
        expect(Edition::StateTransitionErrorReport).to have_received(:new).with(
          error: error,
          edition: edition,
        )
        expect(error_report).to have_received(:call)
      end
    end
  end
end
