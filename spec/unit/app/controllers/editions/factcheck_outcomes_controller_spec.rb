RSpec.describe Editions::FactcheckOutcomesController, type: :controller do
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

    context "when the edition is going to be scheduled" do
      let(:edition) { Edition.new(id: 123, document: document, scheduled_publication: Time.zone.now) }

      it "sets the page title to a 'schedule' call-to-action" do
        expect(assigns(:title)).to eq("Schedule block")
      end
    end

    context "when the edition is going to be published" do
      let(:edition) { Edition.new(id: 123, document: document, scheduled_publication: nil) }

      it "sets the page title to a 'publish' call-to-action" do
        expect(assigns(:title)).to eq("Publish block")
      end
    end

    it "renders the editions/factcheck_outcomes/new template" do
      expect(response).to have_rendered("editions/factcheck_outcomes/new")
    end
  end

  describe "POST to :create" do
    let(:time_now) { Time.current }
    let(:current_user) { instance_double(User, id: 987) }

    before do
      allow(Time).to receive(:current).and_return(time_now)
      allow(Current).to receive(:user).and_return(current_user)
    end

    context "when the form returned is valid" do
      before do
        allow(edition).to receive(:update).and_return(true)
        allow(edition).to receive(:publish!)
      end

      describe "saving the Factcheck outcome details" do
        context "when the editor has indicated that the Factcheck was skipped" do
          before do
            post :create, params: {
              id: 123,
              "factcheck_outcome" => { "factcheck_performed" => false },
            }
          end

          it "saves the Factcheck outcome details" do
            expect(edition).to have_received(:update).with(
              "factcheck_skipped" => true,
              "factcheck_outcome_recorded_at" => time_now,
              "factcheck_outcome_recorded_by" => 987,
            )
          end
        end

        context "when the editor has indicated that the Factcheck was performed" do
          before do
            post :create, params: {
              id: 123,
              "factcheck_outcome" => { "factcheck_performed" => true },
            }
          end

          it "saves the Factcheck outcome details" do
            expect(edition).to have_received(:update).with(
              "factcheck_skipped" => false,
              "factcheck_outcome_recorded_at" => time_now,
              "factcheck_outcome_recorded_by" => 987,
            )
          end
        end
      end

      describe "redirecting to the appropriate next step" do
        before do
          post :create, params: {
            id: 123,
            "factcheck_outcome" => { "factcheck_performed" => true },
          }
        end

        it "should redirect the user to the identify_reviewer step of the factcheck process" do
          expect(response).to redirect_to("/editions/123/factcheck_outcomes/identify_reviewer")
        end
      end
    end

    context "when the form returned is NOT valid" do
      before do
        post :create, params: {
          id: 123,
          "factcheck_outcome" => {},
        }
      end

      it "re-renders the 'new' template to allow the errors to be corrected" do
        expect(response).to redirect_to("/editions/123/factcheck_outcomes/new")
      end

      it "sets an error message" do
        expect(flash.alert).to eq("Indicate whether the Factcheck process has been performed or not")
      end
    end
  end

  describe "GET to :identify_reviewer" do
    before do
      get :identify_reviewer, params: { id: 123 }
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
    end

    context "when the edition is going to be published" do
      let(:edition) { Edition.new(id: 123, document: document, scheduled_publication: nil) }

      it "sets the page title to a 'publish' call-to-action" do
        expect(assigns(:title)).to eq("Publish block")
      end
    end

    it "renders the editions/factcheck_outcomes/identify_reviewer template" do
      expect(response).to have_rendered("editions/factcheck_outcomes/identify_reviewer")
    end
  end

  describe "PUT to :update" do
    let(:time_now) { Time.current }
    let(:current_user) { instance_double(User, id: 987) }

    before do
      allow(Time).to receive(:current).and_return(time_now)
      allow(Current).to receive(:user).and_return(current_user)
      allow(edition).to receive(:update)
      allow(edition).to receive(:schedule!)
      allow(edition).to receive(:publish!)
    end

    context "when the request is valid" do
      before do
        put :update, params: {
          id: 123,
          "factcheck_outcome" => { "factcheck_reviewer" => "Alice" },
        }
      end

      it "should update the edition with the Subject Matter Expert" do
        expect(edition).to have_received(:update).with({ "factcheck_outcome_reviewer" => "Alice" })
      end
    end

    context "when the request is missing a parameter" do
      before do
        put :update, params: {
          id: 123,
          "factcheck_outcome" => {},
        }
      end

      it "redirects to the documents_path to display the most recent edition" do
        expect(response).to redirect_to("/editions/123/factcheck_outcomes/identify_reviewer")
      end

      it "shows an error message" do
        expected_message = "param is missing or the value is empty or invalid: factcheck_outcome"
        expect(flash.alert).to eq(expected_message)
      end
    end

    context "when the edition is due to be scheduled" do
      let(:edition) { Edition.new(id: 123, document: document, scheduled_publication: Time.zone.now) }
      before do
        put :update, params: {
          id: 123,
          "factcheck_outcome" => { "factcheck_reviewer" => "Alice" },
        }
      end
      it "transitions the edition using the 'schedule!' transition" do
        expect(edition).to have_received(:schedule!)
      end

      it "redirects to the documents_path to display the most recent edition" do
        expect(response).to redirect_to("/456")
      end

      it "shows a success message" do
        expected_success_message = "This edition has now been scheduled for publishing"
        expect(flash.notice).to eq(expected_success_message)
      end
    end

    context "when the edition is NOT due to be scheduled" do
      let(:edition) { Edition.new(id: 123, document: document) }

      before do
        put :update, params: {
          id: 123,
          "factcheck_outcome" => { "factcheck_reviewer" => "Alice" },
        }
      end

      it "transitions the edition using the 'publish!' transition" do
        expect(edition).to have_received(:publish!)
      end

      it "redirects to the documents_path to display the most recent edition" do
        expect(response).to redirect_to("/456")
      end

      it "shows a success message" do
        expected_success_message = "This edition has now been published"
        expect(flash.notice).to eq(expected_success_message)
      end
    end

    describe "when the transition fails" do
      context "and the error was something else (e.g. unexpected state)" do
        let(:error_message) do
          "Can't fire event `publish!` in current state `draft` " \
          "for `Edition` with ID 123  (Transitions::InvalidTransition)"
        end

        before do
          allow(edition).to receive(:publish!).and_raise(
            Transitions::InvalidTransition,
            error_message,
          )

          put :update, params: {
            id: 123,
            "factcheck_outcome" => { "factcheck_reviewer" => "Alice" },
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
end
