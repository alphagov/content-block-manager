RSpec.describe Workflow::Steps do
  include SchemaHelper

  let(:document) { build(:document, :contact) }
  let(:edition) { build(:edition, :contact, document:) }
  let(:schema) { edition.document.schema }
  let(:workflow_steps) { Workflow::Steps.for(edition, schema) }

  describe ".for" do
    context "when edition is a new block with no subschemas" do
      before do
        allow(document).to receive(:is_new_block?).and_return(true)
        allow(schema).to receive(:subschemas).and_return([])
      end

      it "returns only steps included in create journey" do
        expected_steps = [
          Workflow::Step.new(:edit_draft, :edit_draft, :update_draft, true),
          Workflow::Step.new(:review, :review, :complete_workflow, true),
          Workflow::Step.new(:confirmation, :confirmation, nil, true),
        ]

        expect(expected_steps).to eq(workflow_steps)
      end
    end

    context "when edition is not a new block" do
      before do
        allow(document).to receive(:is_new_block?).and_return(false)
        allow(schema).to receive(:subschemas).and_return([])
      end

      it "returns all workflow steps" do
        expect(Workflow::Step::ALL).to eq(workflow_steps)
      end
    end

    context "when schema has ungrouped subschemas" do
      let(:subschema1) { double("subschema", id: "contact_details", group: nil) }
      let(:subschema2) { double("subschema", id: "address", group: nil) }

      before do
        allow(document).to receive(:is_new_block?).and_return(false)
        allow(schema).to receive(:subschemas).and_return([subschema1, subschema2])
        allow(edition).to receive(:has_entries_for_subschema_id?).with("contact_details").and_return(true)
        allow(edition).to receive(:has_entries_for_subschema_id?).with("address").and_return(true)
      end

      it "inserts subschema steps after first step" do
        steps = workflow_steps

        expect(Workflow::Step::ALL.[](0)).to eq(steps.[](0))
        expect(:embedded_contact_details).to eq(steps.[](1).name)
        expect(:embedded_address).to eq(steps.[](2).name)
        expect(Workflow::Step::ALL.[](1..)).to eq(steps.[](3..))
      end

      it "creates subschema steps with correct attributes" do
        subschema_step = workflow_steps[1]

        expect(:embedded_contact_details).to eq(subschema_step.name)
        expect(:embedded_contact_details).to eq(subschema_step.show_action)
        expect(:redirect_to_next_step).to eq(subschema_step.update_action)
        expect(true).to eq(subschema_step.included_in_create_journey)
      end
    end

    context "when schema has grouped subschemas" do
      let(:subschema1) { double("subschema", id: "phone", group: "contact_info") }
      let(:subschema2) { double("subschema", id: "email", group: "contact_info") }
      let(:subschema3) { double("subschema", id: "address", group: nil) }

      before do
        allow(document).to receive(:is_new_block?).and_return(false)
        allow(schema).to receive(:subschemas).and_return([subschema1, subschema2, subschema3])
        allow(edition).to receive(:has_entries_for_subschema_id?).with("phone").and_return(true)
        allow(edition).to receive(:has_entries_for_subschema_id?).with("email").and_return(true)
        allow(edition).to receive(:has_entries_for_subschema_id?).with("address").and_return(true)
      end

      it "inserts group step and ungrouped subschema steps" do
        steps = workflow_steps

        expect(Workflow::Step::ALL.[](0)).to eq(steps.[](0))
        expect(:group_contact_info).to eq(steps.[](1).name)
        expect(:embedded_address).to eq(steps.[](2).name)
        expect(Workflow::Step::ALL.[](1..)).to eq(steps.[](3..))
      end

      it "creates group steps with correct attributes" do
        group_step = workflow_steps[1]

        expect(:group_contact_info).to eq(group_step.name)
        expect(:group_contact_info).to eq(group_step.show_action)
        expect(:redirect_to_next_step).to eq(group_step.update_action)
        expect(true).to eq(group_step.included_in_create_journey)
      end
    end

    context "when subschemas have no entries" do
      let(:subschema1) { double("subschema", id: "contact_details", group: nil) }
      let(:subschema2) { double("subschema", id: "address", group: nil) }

      before do
        allow(document).to receive(:is_new_block?).and_return(false)
        allow(schema).to receive(:subschemas).and_return([subschema1, subschema2])
        allow(edition).to receive(:has_entries_for_subschema_id?).with("contact_details").and_return(false)
        allow(edition).to receive(:has_entries_for_subschema_id?).with("address").and_return(true)
      end

      it "skips subschemas without entries" do
        steps = workflow_steps

        expect(Workflow::Step::ALL.[](0)).to eq(steps.[](0))
        expect(:embedded_address).to eq(steps.[](1).name)
        assert(steps.none? { |s| s.name == :embedded_contact_details })
      end
    end

    context "when all subschemas in a group have no entries" do
      let(:subschema1) { double("subschema", id: "phone", group: "contact_info") }
      let(:subschema2) { double("subschema", id: "email", group: "contact_info") }

      before do
        allow(document).to receive(:is_new_block?).and_return(false)
        allow(schema).to receive(:subschemas).and_return([subschema1, subschema2])
        allow(edition).to receive(:has_entries_for_subschema_id?).with("phone").and_return(false)
        allow(edition).to receive(:has_entries_for_subschema_id?).with("email").and_return(false)
      end

      it "skips the entire group" do
        steps = workflow_steps

        assert(steps.none? { |s| s.name == :group_contact_info })
      end
    end

    context "when some subschemas in a group have entries" do
      let(:subschema1) { double("subschema", id: "phone", group: "contact_info") }
      let(:subschema2) { double("subschema", id: "email", group: "contact_info") }

      before do
        allow(document).to receive(:is_new_block?).and_return(false)
        allow(schema).to receive(:subschemas).and_return([subschema1, subschema2])
        allow(edition).to receive(:has_entries_for_subschema_id?).with("phone").and_return(true)
        allow(edition).to receive(:has_entries_for_subschema_id?).with("email").and_return(false)
      end

      it "includes the group step" do
        steps = workflow_steps

        assert(steps.any? { |s| s.name == :group_contact_info })
      end
    end

    context "when edition is a new block with subschemas" do
      let(:subschema1) { double("subschema", id: "contact_details", group: nil) }

      before do
        allow(document).to receive(:is_new_block?).and_return(true)
        allow(schema).to receive(:subschemas).and_return([subschema1])
        allow(edition).to receive(:has_entries_for_subschema_id?).with("contact_details").and_return(true)
      end

      it "includes only steps from create journey with subschema steps" do
        expected_steps = [
          Workflow::Step.new(:edit_draft, :edit_draft, :update_draft, true),
          Workflow::Step.new(:embedded_contact_details, :embedded_contact_details, :redirect_to_next_step, true),
          Workflow::Step.new(:review, :review, :complete_workflow, true),
          Workflow::Step.new(:confirmation, :confirmation, nil, true),
        ]

        expect(expected_steps).to eq(workflow_steps)
      end
    end
  end
end
