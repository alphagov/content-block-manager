RSpec.describe BlocksController, type: :controller do
  describe "#edition_params" do
    let(:user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when passed attributes" do
      let(:raw_params) do
        {
          edition: {
            lead_organisation_id: "123",
            instructions_to_publishers: "Some instructions",
            title: "A title",
            unpermitted_field: "should be filtered out",
          },
        }
      end

      before do
        controller.params = ActionController::Parameters.new(raw_params)
      end

      it "permits the expected top-level attributes" do
        result = controller.send(:edition_params)

        expect(result[:lead_organisation_id]).to eq("123")
        expect(result[:instructions_to_publishers]).to eq("Some instructions")
        expect(result[:title]).to eq("A title")
      end

      it "filters out unpermitted attributes" do
        result = controller.send(:edition_params)

        expect(result).not_to have_key(:unpermitted_field)
      end

      it "merges in the current_user as creator" do
        result = controller.send(:edition_params)

        expect(result[:creator]).to eq(user)
      end

      it "returns permitted params" do
        result = controller.send(:edition_params)

        expect(result.permitted?).to be true
      end
    end

    context "when edition key is missing" do
      before do
        controller.params = ActionController::Parameters.new({})
      end

      it "raises ActionController::ParameterMissing" do
        expect { controller.send(:edition_params) }
          .to raise_error(ActionController::ParameterMissing,
                          "param is missing or the value is empty or invalid: edition")
      end
    end
  end
end
