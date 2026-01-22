RSpec.describe Editions::StatusTransitionsController, type: :controller do
  include LoginHelpers
  let(:user) { create :user }
  let(:document) { instance_double(Document, id: 456) }
  let(:edition) { create(:edition, document: create(:document)) }
  let(:transition_state_outcome) do
    {
      ready_for_review: "awaiting_review",
      publish: "published",
      schedule: "scheduled",
      delete: "deleted",
      supersede: "superseded",
    }
  end

  before do
    login_as(user)
    allow(Edition).to receive(:find).and_return(edition)
  end

  describe "#create" do
    # TODO: :schedule requires validation and we should handle it here if we want to use this controller for scheduling
    #       :complete_draft is excluded as it's invoked only through the WorkflowCompletion command
    Edition.new.available_transitions.reject { |tr| tr.in?(%i[complete_draft schedule]) }.each do |transition|
      context "when the valid transition is '#{transition}'" do
        transition_method = "#{transition}!"

        it "retrieves the given edition" do
          post :create, params: { id: 123, transition: transition }

          expect(Edition).to have_received(:find).with("123")
        end

        it "attempts to transition the given edition to the relevant state" do
          allow(edition).to receive(transition_method)
          post :create, params: { id: 123, transition: transition }

          expect(edition).to have_received(transition_method)
        end

        context "when the transition succeeds" do
          it "redirects to the correct page" do
            post :create, params: { id: 123, transition: transition }

            if transition == :delete
              expect(response).to redirect_to(root_path)
            else
              expect(response).to redirect_to(document_path(edition.document))
            end
          end

          it "shows a success message" do
            post :create, params: { id: 123, transition: transition }

            expected_success_message = Edition::StateTransitionMessage.new(
              edition: edition,
              state: edition.reload.state,
            ).to_s
            expect(flash.notice).to eq(expected_success_message)
          end
        end
      end
    end

    context "when the transition is not supported by this controller" do
      %i[complete_draft schedule].each do |transition|
        context "when attempting the '#{transition}' transition" do
          it "raises an UnsupportedTransitionError" do
            expect {
              post :create, params: { id: 123, transition: transition }
            }.to raise_error(
              Editions::StatusTransitionsController::UnsupportedTransitionError,
              "Transition event '#{transition}' is not supported by this controller",
            )
          end
        end
      end
    end

    context "when the transition is invalid" do
      let(:edition_invalid_for_transition) do
        document = create(:document, id: 456)
        create(:edition, state: "awaiting_review", id: 123, document: document)
      end

      before do
        allow(Edition).to receive(:find).and_return(edition_invalid_for_transition)
        allow(GovukError).to receive(:notify)

        post :create, params: { id: 123, transition: :ready_for_review }
      end

      it "redirects to the show page" do
        expect(response).to redirect_to(document_path(456))
      end

      it "shows an error message " do
        expected_error_message = I18n.t("edition.states.transition_error")

        expect(flash.alert).to eq(expected_error_message)
      end

      it "records the error details using GovukError to facilitate remediation" do
        expected_error_details = "Can't fire event `ready_for_review` in current state " \
          "`awaiting_review` for `Edition` with ID 123 "

        expect(GovukError).to have_received(:notify).with(
          expected_error_details,
          extra: {
            edition_id: 123,
            document_id: 456,
          },
        )
      end
    end

    context "when the transition requested is not recognised" do
      it "raises an UnknownTransitionError" do
        expect {
          post :create, params: { id: 123, transition: :unknown_transition }
        }.to raise_error(
          Editions::StatusTransitionsController::UnknownTransitionError,
          "Transition event 'unknown_transition' is not recognised",
        )
      end
    end
  end
end
