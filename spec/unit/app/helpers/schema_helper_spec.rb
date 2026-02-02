RSpec.describe SchemaHelper, type: :helper do
  include Rails.application.routes.url_helpers

  describe "#redirect_url_for_subschema" do
    let(:edition) { build_stubbed(:edition, :contact) }
    let(:subschema) { double(:subschema, group:, id: "my_subschema") }

    context "when the subschema has a group" do
      let(:group) { nil }

      it "should generate a url with the subschema's step" do
        expect(workflow_path(edition, { step: "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}" })).to eq(redirect_url_for_subschema(subschema, edition))
      end
    end

    context "when the subschema has no group" do
      let(:group) { "some_group" }

      it "should generate a url with the subschema's group" do
        expect(workflow_path(edition, { step: "#{Workflow::Step::GROUP_PREFIX}#{subschema.group}" })).to eq(redirect_url_for_subschema(subschema, edition))
      end
    end
  end
end
