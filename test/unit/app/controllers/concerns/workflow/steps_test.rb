require "test_helper"

class Workflow::StepsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  include SchemaHelper

  let(:document) { build(:document, :contact) }
  let(:edition) { build(:edition, :contact, document:) }
  let(:schema) { edition.document.schema }
  let(:workflow_steps) { Workflow::Steps.for(edition, schema) }

  describe ".for" do
    context "when edition is a new block with no subschemas" do
      before do
        document.stubs(:is_new_block?).returns(true)
        schema.stubs(:subschemas).returns([])
      end

      it "returns only steps included in create journey" do
        expected_steps = [
          Workflow::Step.new(:edit_draft, :edit_draft, :update_draft, true),
          Workflow::Step.new(:review, :review, :validate_review_page, true),
          Workflow::Step.new(:confirmation, :confirmation, nil, true),
        ]

        assert_equal workflow_steps, expected_steps
      end
    end

    context "when edition is not a new block" do
      before do
        document.stubs(:is_new_block?).returns(false)
        schema.stubs(:subschemas).returns([])
      end

      it "returns all workflow steps" do
        assert_equal workflow_steps, Workflow::Step::ALL
      end
    end

    context "when schema has ungrouped subschemas" do
      let(:subschema1) { stub("subschema", id: "contact_details", group: nil) }
      let(:subschema2) { stub("subschema", id: "address", group: nil) }

      before do
        document.stubs(:is_new_block?).returns(false)
        schema.stubs(:subschemas).returns([subschema1, subschema2])
        edition.stubs(:has_entries_for_subschema_id?).with("contact_details").returns(true)
        edition.stubs(:has_entries_for_subschema_id?).with("address").returns(true)
      end

      it "inserts subschema steps after first step" do
        steps = workflow_steps

        assert_equal steps[0], Workflow::Step::ALL[0]
        assert_equal steps[1].name, :embedded_contact_details
        assert_equal steps[2].name, :embedded_address
        assert_equal steps[3..], Workflow::Step::ALL[1..]
      end

      it "creates subschema steps with correct attributes" do
        subschema_step = workflow_steps[1]

        assert_equal subschema_step.name, :embedded_contact_details
        assert_equal subschema_step.show_action, :embedded_contact_details
        assert_equal subschema_step.update_action, :redirect_to_next_step
        assert_equal subschema_step.included_in_create_journey, true
      end
    end

    context "when schema has grouped subschemas" do
      let(:subschema1) { stub("subschema", id: "phone", group: "contact_info") }
      let(:subschema2) { stub("subschema", id: "email", group: "contact_info") }
      let(:subschema3) { stub("subschema", id: "address", group: nil) }

      before do
        document.stubs(:is_new_block?).returns(false)
        schema.stubs(:subschemas).returns([subschema1, subschema2, subschema3])
        edition.stubs(:has_entries_for_subschema_id?).with("phone").returns(true)
        edition.stubs(:has_entries_for_subschema_id?).with("email").returns(true)
        edition.stubs(:has_entries_for_subschema_id?).with("address").returns(true)
      end

      it "inserts group step and ungrouped subschema steps" do
        steps = workflow_steps

        assert_equal steps[0], Workflow::Step::ALL[0]
        assert_equal steps[1].name, :group_contact_info
        assert_equal steps[2].name, :embedded_address
        assert_equal steps[3..], Workflow::Step::ALL[1..]
      end

      it "creates group steps with correct attributes" do
        group_step = workflow_steps[1]

        assert_equal group_step.name, :group_contact_info
        assert_equal group_step.show_action, :group_contact_info
        assert_equal group_step.update_action, :redirect_to_next_step
        assert_equal group_step.included_in_create_journey, true
      end
    end

    context "when subschemas have no entries" do
      let(:subschema1) { stub("subschema", id: "contact_details", group: nil) }
      let(:subschema2) { stub("subschema", id: "address", group: nil) }

      before do
        document.stubs(:is_new_block?).returns(false)
        schema.stubs(:subschemas).returns([subschema1, subschema2])
        edition.stubs(:has_entries_for_subschema_id?).with("contact_details").returns(false)
        edition.stubs(:has_entries_for_subschema_id?).with("address").returns(true)
      end

      it "skips subschemas without entries" do
        steps = workflow_steps

        assert_equal steps[0], Workflow::Step::ALL[0]
        assert_equal steps[1].name, :embedded_address
        assert(steps.none? { |s| s.name == :embedded_contact_details })
      end
    end

    context "when all subschemas in a group have no entries" do
      let(:subschema1) { stub("subschema", id: "phone", group: "contact_info") }
      let(:subschema2) { stub("subschema", id: "email", group: "contact_info") }

      before do
        document.stubs(:is_new_block?).returns(false)
        schema.stubs(:subschemas).returns([subschema1, subschema2])
        edition.stubs(:has_entries_for_subschema_id?).with("phone").returns(false)
        edition.stubs(:has_entries_for_subschema_id?).with("email").returns(false)
      end

      it "skips the entire group" do
        steps = workflow_steps

        assert(steps.none? { |s| s.name == :group_contact_info })
      end
    end

    context "when some subschemas in a group have entries" do
      let(:subschema1) { stub("subschema", id: "phone", group: "contact_info") }
      let(:subschema2) { stub("subschema", id: "email", group: "contact_info") }

      before do
        document.stubs(:is_new_block?).returns(false)
        schema.stubs(:subschemas).returns([subschema1, subschema2])
        edition.stubs(:has_entries_for_subschema_id?).with("phone").returns(true)
        edition.stubs(:has_entries_for_subschema_id?).with("email").returns(false)
      end

      it "includes the group step" do
        steps = workflow_steps

        assert(steps.any? { |s| s.name == :group_contact_info })
      end
    end

    context "when edition is a new block with subschemas" do
      let(:subschema1) { stub("subschema", id: "contact_details", group: nil) }

      before do
        document.stubs(:is_new_block?).returns(true)
        schema.stubs(:subschemas).returns([subschema1])
        edition.stubs(:has_entries_for_subschema_id?).with("contact_details").returns(true)
      end

      it "includes only steps from create journey with subschema steps" do
        expected_steps = [
          Workflow::Step.new(:edit_draft, :edit_draft, :update_draft, true),
          Workflow::Step.new(:embedded_contact_details, :embedded_contact_details, :redirect_to_next_step, true),
          Workflow::Step.new(:review, :review, :validate_review_page, true),
          Workflow::Step.new(:confirmation, :confirmation, nil, true),
        ]

        assert_equal workflow_steps, expected_steps
      end
    end
  end
end
