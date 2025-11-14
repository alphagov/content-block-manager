RSpec.describe SchemaHelper, type: :helper do
  include Rails.application.routes.url_helpers

  let(:schema) { double(:schema) }

  let(:group_1_subschemas) do
    [
      double(:subschema, group: "group_1"),
      double(:subschema, group: "group_1"),
    ]
  end

  let(:group_2_subschemas) do
    [
      double(:subschema, group: "group_2"),
      double(:subschema, group: "group_2"),
      double(:subschema, group: "group_2"),
    ]
  end

  let(:subschemas_without_groups) do
    [
      double(:subschema, group: nil),
      double(:subschema, group: nil),
      double(:subschema, group: nil),
      double(:subschema, group: nil),
      double(:subschema, group: nil),
    ]
  end

  before do
    allow(schema).to receive(:subschemas).and_return([*group_1_subschemas, *group_2_subschemas, *subschemas_without_groups])
  end

  describe "#grouped_subschemas" do
    it "returns all grouped subschemas" do
      expect({ "group_1" => group_1_subschemas, "group_2" => group_2_subschemas }).to eq(grouped_subschemas(schema))
    end
  end

  describe "#ungrouped_subschemas" do
    it "returns all ungrouped subschemas" do
      expect(subschemas_without_groups).to eq(ungrouped_subschemas(schema))
    end
  end

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
