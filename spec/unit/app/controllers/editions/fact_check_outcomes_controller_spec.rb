RSpec.describe Editions::FactCheckOutcomesController, type: :controller do
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

    context "when the edition is going to be scheduled" do
      let(:edition) { create(:edition, :pension, id: 123, document: document, scheduled_publication: Time.zone.now) }

      it "sets the page title to a 'schedule' call-to-action" do
        expect(assigns(:title)).to eq("Schedule block")
      end
    end

    context "when the edition is going to be published" do
      let(:edition) { create(:edition, :pension, id: 123, document: document, scheduled_publication: nil) }

      it "sets the page title to a 'publish' call-to-action" do
        expect(assigns(:title)).to eq("Publish block")
      end
    end

    it "renders the editions/fact_check_outcomes/new template" do
      expect(response).to have_rendered("editions/fact_check_outcomes/new")
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
        allow(edition).to receive(:create_fact_check_outcome!)
        allow(edition).to receive(:publish!)
      end

      describe "saving the Fact check outcome details" do
        context "when the editor has indicated that the fact check was skipped" do
          before do
            post :create, params: {
              id: 123,
              "fact_check_outcome" => { "fact_check_performed" => false },
            }
          end

          it "saves the fact check outcome details" do
            expect(edition).to have_received(:create_fact_check_outcome!).with(
              "skipped" => true,
              "creator" => current_user,
            )
          end

          it "publishes the edition" do
            expect(edition).to have_received(:publish!)
          end

          it "redirects to the document path" do
            expect(response).to redirect_to("/456")
          end
        end

        context "when the editor has indicated that the fact check was performed" do
          before do
            post :create, params: {
              id: 123,
              "fact_check_outcome" => { "fact_check_performed" => true },
            }
          end

          it "saves the fact check outcome details" do
            expect(edition).to have_received(:create_fact_check_outcome!).with(
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
            "fact_check_outcome" => { "fact_check_performed" => true },
          }
        end

        it "should redirect the user to the identify_performer step of the fact check process" do
          expect(response).to redirect_to("/editions/123/fact_check_outcomes/identify_performer")
        end
      end
    end

    context "when the form returned is NOT valid" do
      before do
        post :create, params: {
          id: 123,
          "fact_check_outcome" => {},
        }
      end

      it "re-renders the 'new' template to allow the errors to be corrected" do
        expect(response).to redirect_to("/editions/123/fact_check_outcomes/new")
      end

      it "sets an error message" do
        expect(flash.alert).to eq(I18n.t("edition.outcomes.errors.missing_outcome.fact_check"))
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

    context "when the edition is going to be scheduled" do
      let(:edition) { Edition.new(id: 123, document: document, scheduled_publication: Time.zone.now) }

      it "sets the page title to a 'schedule' call-to-action" do
        expect(assigns(:title)).to eq("Schedule block")
      end

      it "sets the call to action to a 'schedule' call-to-action" do
        expect(assigns(:transition)).to eq("schedule")
      end
    end

    context "when the edition is going to be published" do
      let(:edition) { Edition.new(id: 123, document: document, scheduled_publication: nil) }

      it "sets the page title to a 'publish' call-to-action" do
        expect(assigns(:title)).to eq("Publish block")
      end

      it "sets the call to action to a 'publish' call-to-action" do
        expect(assigns(:transition)).to eq("publish")
      end
    end

    it "renders the editions/fact_check_outcomes/identify_performer template" do
      expect(response).to have_rendered("editions/fact_check_outcomes/identify_performer")
    end
  end

  describe "PUT to :update" do
    let(:time_now) { Time.current }
    let(:current_user) { instance_double(User, id: 987) }
    let(:fact_check_outcome) { spy(FactCheckOutcome) }

    before do
      allow(Time).to receive(:current).and_return(time_now)
      allow(Current).to receive(:user).and_return(current_user)
      allow(edition).to receive(:update)
      allow(edition).to receive(:schedule!)
      allow(edition).to receive(:publish!)
      allow(edition).to receive(:fact_check_outcome).and_return(fact_check_outcome)
    end

    context "when the request is valid" do
      before do
        put :update, params: {
          id: 123,
          "fact_check_outcome" => { "fact_check_performer" => "Alice" },
        }
      end

      it "should update the edition with the Subject Matter Expert" do
        expect(edition.fact_check_outcome).to have_received(:update!).with({ "performer" => "Alice" })
      end
    end

    context "when the performer field is missing" do
      before do
        put :update, params: {
          id: 123,
          "fact_check_outcome" => {},
        }
        allow(edition).to receive(:schedule!)
        allow(edition).to receive(:publish!)
      end

      it "redirects to the same page to prevent the user progressing" do
        expect(response).to redirect_to("/editions/123/fact_check_outcomes/identify_performer")
      end

      it "shows an error message" do
        expected_message = I18n.t("edition.outcomes.errors.missing_performer.fact_check")
        expect(flash.alert).to eq(expected_message)
      end

      it "should not transition to the next state" do
        expect(edition).not_to have_received(:schedule!)
        expect(edition).not_to have_received(:publish!)
      end
    end

    context "when the performer field is blank" do
      before do
        put :update, params: {
          id: 123,
          "fact_check_outcome" => { "fact_check_performer" => "" },
        }
        allow(edition).to receive(:schedule!)
        allow(edition).to receive(:publish!)
      end

      it "redirects to the same page to prevent the user progressing" do
        expect(response).to redirect_to("/editions/123/fact_check_outcomes/identify_performer")
      end

      it "shows an error message" do
        expected_message = I18n.t("edition.outcomes.errors.missing_performer.fact_check")
        expect(flash.alert).to eq(expected_message)
      end

      it "should not transition to the next state" do
        expect(edition).not_to have_received(:schedule!)
        expect(edition).not_to have_received(:publish!)
      end
    end

    context "when the edition is due to be scheduled" do
      let(:edition) { Edition.new(id: 123, document: document, scheduled_publication: Time.zone.now) }
      before do
        put :update, params: {
          id: 123,
          "fact_check_outcome" => { "fact_check_performer" => "Alice" },
        }
      end
      it "transitions the edition using the 'schedule!' transition" do
        expect(edition).to have_received(:schedule!)
      end

      it "redirects to the documents_path to display the most recent edition" do
        expect(response).to redirect_to("/456")
      end

      it "shows a success message" do
        expected_success_message = Edition::StateTransitionMessage.new(
          edition: edition,
          state: :scheduled,
        ).to_s
        expect(flash[:success]).to eq(expected_success_message)
      end
    end

    context "when the edition is NOT due to be scheduled" do
      let(:edition) { Edition.new(id: 123, document: document) }

      before do
        put :update, params: {
          id: 123,
          "fact_check_outcome" => { "fact_check_performer" => "Alice" },
        }
      end

      it "transitions the edition using the 'publish!' transition" do
        expect(edition).to have_received(:publish!)
      end

      it "redirects to the documents_path to display the most recent edition" do
        expect(response).to redirect_to("/456")
      end

      it "shows a success message" do
        expected_success_message = Edition::StateTransitionMessage.new(
          edition: edition,
          state: :published,
        ).to_s
        expect(flash[:success]).to eq(expected_success_message)
      end
    end

    describe "when the transition fails" do
      context "and the error was something else (e.g. unexpected state)" do
        let(:error_message) do
          "Can't fire event `publish!` in current state `draft` " \
          "for `Edition` with ID 123  (Transitions::InvalidTransition)"
        end

        let(:error_report) { instance_double(Edition::StateTransitionErrorReport, call: nil) }
        let(:error) { Transitions::InvalidTransition.new(error_message) }

        before do
          allow(edition).to receive(:publish!).and_raise(error)

          allow(Edition::StateTransitionErrorReport).to receive(:new).and_return(error_report)

          put :update, params: {
            id: 123,
            "fact_check_outcome" => { "fact_check_performer" => "Alice" },
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
end
