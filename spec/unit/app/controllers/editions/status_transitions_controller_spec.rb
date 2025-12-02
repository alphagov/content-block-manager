RSpec.describe Editions::StatusTransitionsController, type: :controller do
  include LoginHelpers
  let(:user) { create :user }
  let(:document) { instance_double(Document, id: 456) }
  let(:edition) { build(:edition, document: create(:document)) }
  let(:transition_state_outcome) do
    {
      ready_for_2i: "awaiting_review",
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
    Edition.new.available_transitions.reject { |tr| tr == :schedule }.each do |transition|
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
          expected_success_message = "Edition has been moved into state '#{transition_state_outcome[transition]}'"

          post :create, params: { id: 123, transition: transition }

          expect(flash.notice).to eq(expected_success_message)
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
      end

      it "redirects to the show page" do
        post :create, params: { id: 123, transition: :ready_for_2i }

        expect(response).to redirect_to(document_path(456))
      end

      it "shows a failure message with the transition error" do
        expected_failure_message = "Error: we can not change the status of this edition. " \
          "Can't fire event `ready_for_2i` in current state `awaiting_review` for `Edition` with ID 123 "

        post :create, params: { id: 123, transition: :ready_for_2i }

        expect(flash.alert).to eq(expected_failure_message)
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
