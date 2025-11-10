class WorkflowTestClass
  class << self
    def before_action(method)
      @before_actions ||= []
      @before_actions << method
    end
  end

  include Workflow::HasSteps

  attr_reader :params

  def initialize(params)
    @params = params
    self.class.instance_variable_get("@before_actions").each do |method|
      send(method)
    end
  end
end

RSpec.describe Workflow::HasSteps, type: :integration do
  include IntegrationSpecHelpers

  let(:document) { build(:document, :pension) }
  let(:edition) { build(:edition, :pension, document: document) }

  let!(:schema) { stub_request_for_schema(document.block_type) }

  before do
    allow(Edition).to receive(:find).with(edition.id).and_return(edition)
    allow(document).to receive(:schema).and_return(schema)
  end

  let(:workflow) { WorkflowTestClass.new({ id: edition.id, step: }) }

  describe "#current_step" do
    Workflow::Step::ALL.each do |step|
      describe "when step name is #{step.name}" do
        let(:step) { step.name }

        it "returns the step" do
          expect(step).to eq(workflow.current_step)
        end
      end
    end
  end

  describe "#next_step" do
    [
      %i[edit_draft review_links],
      %i[review_links internal_note],
      %i[internal_note change_note],
      %i[change_note schedule_publishing],
      %i[schedule_publishing review],
      %i[review confirmation],
    ].each do |current_step, expected_step|
      describe "when current_step is #{current_step}" do
        let(:step) { current_step }

        it "returns #{expected_step} step" do
          expect(expected_step).to eq(workflow.next_step.name)
        end
      end
    end
  end

  describe "#previous_step" do
    [
      %i[review_links edit_draft],
      %i[internal_note review_links],
      %i[change_note internal_note],
      %i[schedule_publishing change_note],
      %i[review schedule_publishing],
    ].each do |current_step, expected_step|
      describe "when current_step is #{current_step}" do
        let(:step) { current_step }

        it "returns #{expected_step} step" do
          expect(expected_step).to eq(workflow.previous_step.name)
        end
      end
    end
  end

  describe "when the content block is new" do
    let(:step) { "something" }

    before do
      expect(document).to receive(:is_new_block?).at_least(:once).and_return(true)
    end

    it "removes steps not included in the create journey" do
      expect(workflow.steps).to eq([
        Workflow::Step.new(:edit_draft, :edit_draft, :update_draft, true),
        Workflow::Step.new(:review, :review, :complete_workflow, true),
        Workflow::Step.new(:confirmation, :confirmation, nil, true),
      ].flatten)
    end

    describe "#next_step" do
      [
        %i[edit_draft review],
        %i[review confirmation],
      ].each do |current_step, expected_step|
        describe "when current_step is #{current_step}" do
          let(:step) { current_step }

          it "returns #{expected_step} step" do
            expect(expected_step).to eq(workflow.next_step.name)
          end
        end
      end
    end

    describe "#previous_step" do
      [
        %i[review edit_draft],
      ].each do |current_step, expected_step|
        describe "when current_step is #{current_step}" do
          let(:step) { current_step }

          it "returns #{expected_step} step" do
            expect(expected_step).to eq(workflow.previous_step.name)
          end
        end
      end
    end
  end

  describe "when a schema has subschemas" do
    let(:subschemas) do
      [
        double("subschema", id: "something", group: nil),
        double("subschema", id: "something_else", group: nil),
      ]
    end

    let!(:schema) { stub_request_for_schema(document.block_type, subschemas:) }

    let(:step) { "something" }

    before do
      allow(edition).to receive(:has_entries_for_subschema_id?).with("something").and_return(true)
      allow(edition).to receive(:has_entries_for_subschema_id?).with("something_else").and_return(true)
    end

    describe "#steps" do
      it "inserts the subschemas into the flow" do
        expect(workflow.steps).to eq([
          Workflow::Step::ALL[0],
          Workflow::Step.new(:embedded_something, :embedded_something, :redirect_to_next_step, true),
          Workflow::Step.new(:embedded_something_else, :embedded_something_else, :redirect_to_next_step, true),
          Workflow::Step::ALL[1..],
        ].flatten)
      end

      describe "when there are entries missing for a given subschema" do
        before do
          allow(edition).to receive(:has_entries_for_subschema_id?).with("something").and_return(false)
          allow(edition).to receive(:has_entries_for_subschema_id?).with("something_else").and_return(true)
        end

        it "skips the subschemas without data" do
          expect(workflow.steps).to eq([
            Workflow::Step::ALL[0],
            Workflow::Step.new(:embedded_something_else, :embedded_something_else, :redirect_to_next_step, true),
            Workflow::Step::ALL[1..],
          ].flatten)
        end
      end
    end

    describe "#next_step" do
      [
        %i[edit_draft embedded_something],
        %i[embedded_something embedded_something_else],
        %i[embedded_something_else review_links],
        %i[review_links internal_note],
        %i[internal_note change_note],
        %i[change_note schedule_publishing],
        %i[schedule_publishing review],
        %i[review confirmation],
      ].each do |current_step, expected_step|
        describe "when current_step is #{current_step}" do
          let(:step) { current_step }

          it "returns #{expected_step} step" do
            expect(expected_step).to eq(workflow.next_step.name)
          end
        end
      end
    end

    describe "#previous_step" do
      [
        %i[embedded_something edit_draft],
        %i[embedded_something_else embedded_something],
        %i[review_links embedded_something_else],
        %i[internal_note review_links],
        %i[change_note internal_note],
        %i[schedule_publishing change_note],
        %i[review schedule_publishing],
      ].each do |current_step, expected_step|
        describe "when current_step is #{current_step}" do
          let(:step) { current_step }

          it "returns #{expected_step} step" do
            expect(expected_step).to eq(workflow.previous_step.name)
          end
        end
      end
    end

    describe "and the content block is new" do
      before do
        expect(document).to receive(:is_new_block?).at_least(:once).and_return(true)
      end

      it "removes steps not included in the create journey" do
        expect(workflow.steps).to eq([
          Workflow::Step.new(:edit_draft, :edit_draft, :update_draft, true),
          Workflow::Step.new(:embedded_something, :embedded_something, :redirect_to_next_step, true),
          Workflow::Step.new(:embedded_something_else, :embedded_something_else, :redirect_to_next_step, true),
          Workflow::Step.new(:review, :review, :complete_workflow, true),
          Workflow::Step.new(:confirmation, :confirmation, nil, true),
        ].flatten)
      end

      describe "#next_step" do
        [
          %i[edit_draft embedded_something],
          %i[embedded_something embedded_something_else],
          %i[embedded_something_else review],
          %i[review confirmation],
        ].each do |current_step, expected_step|
          describe "when current_step is #{current_step}" do
            let(:step) { current_step }

            it "returns #{expected_step} step" do
              expect(expected_step).to eq(workflow.next_step.name)
            end
          end
        end
      end

      describe "#previous_step" do
        [
          %i[embedded_something edit_draft],
          %i[embedded_something_else embedded_something],
          %i[review embedded_something_else],
        ].each do |current_step, expected_step|
          describe "when current_step is #{current_step}" do
            let(:step) { current_step }

            it "returns #{expected_step} step" do
              expect(expected_step).to eq(workflow.previous_step.name)
            end
          end
        end
      end
    end
  end

  describe "when a schema has grouped subschemas" do
    let(:subschemas) do
      [
        double("subschema", id: "something", group: "my_group"),
        double("subschema", id: "something_else", group: "my_group"),
        double("subschema", id: "ungrouped", group: nil),
      ]
    end

    let!(:schema) { stub_request_for_schema(document.block_type, subschemas:) }

    let(:step) { "something" }

    before do
      allow(edition).to receive(:has_entries_for_subschema_id?).with("something").and_return(true)
      allow(edition).to receive(:has_entries_for_subschema_id?).with("something_else").and_return(true)
      allow(edition).to receive(:has_entries_for_subschema_id?).with("ungrouped").and_return(true)
    end

    describe "#steps" do
      it "inserts the subschemas into the flow" do
        expect(workflow.steps).to eq([
          Workflow::Step::ALL[0],
          Workflow::Step.new(:group_my_group, :group_my_group, :redirect_to_next_step, true),
          Workflow::Step.new(:embedded_ungrouped, :embedded_ungrouped, :redirect_to_next_step, true),
          Workflow::Step::ALL[1..],
        ].flatten)
      end

      describe "when there are entries missing for a given subschema" do
        before do
          allow(edition).to receive(:has_entries_for_subschema_id?).with("something").and_return(false)
          allow(edition).to receive(:has_entries_for_subschema_id?).with("something_else").and_return(false)
          allow(edition).to receive(:has_entries_for_subschema_id?).with("ungrouped").and_return(true)
        end

        it "skips the subschemas without data" do
          expect(workflow.steps).to eq([
            Workflow::Step::ALL[0],
            Workflow::Step.new(:embedded_ungrouped, :embedded_ungrouped, :redirect_to_next_step, true),
            Workflow::Step::ALL[1..],
          ].flatten)
        end

        describe "when there are entries missing for only some subschemas in a group" do
          before do
            allow(edition).to receive(:has_entries_for_subschema_id?).with("something").and_return(false)
            allow(edition).to receive(:has_entries_for_subschema_id?).with("something_else").and_return(true)
            allow(edition).to receive(:has_entries_for_subschema_id?).with("ungrouped").and_return(true)
          end

          it "retains the group" do
            expect(workflow.steps).to eq([
              Workflow::Step::ALL[0],
              Workflow::Step.new(:group_my_group, :group_my_group, :redirect_to_next_step, true),
              Workflow::Step.new(:embedded_ungrouped, :embedded_ungrouped, :redirect_to_next_step, true),
              Workflow::Step::ALL[1..],
            ].flatten)
          end
        end
      end
    end

    describe "#next_step" do
      [
        %i[edit_draft group_my_group],
        %i[group_my_group embedded_ungrouped],
        %i[embedded_ungrouped review_links],
        %i[review_links internal_note],
        %i[internal_note change_note],
        %i[change_note schedule_publishing],
        %i[schedule_publishing review],
        %i[review confirmation],
      ].each do |current_step, expected_step|
        describe "when current_step is #{current_step}" do
          let(:step) { current_step }

          it "returns #{expected_step} step" do
            expect(expected_step).to eq(workflow.next_step.name)
          end
        end
      end
    end

    describe "#previous_step" do
      [
        %i[group_my_group edit_draft],
        %i[embedded_ungrouped group_my_group],
        %i[review_links embedded_ungrouped],
        %i[internal_note review_links],
        %i[change_note internal_note],
        %i[schedule_publishing change_note],
        %i[review schedule_publishing],
      ].each do |current_step, expected_step|
        describe "when current_step is #{current_step}" do
          let(:step) { current_step }

          it "returns #{expected_step} step" do
            expect(expected_step).to eq(workflow.previous_step.name)
          end
        end
      end
    end

    describe "and the content block is new" do
      before do
        expect(document).to receive(:is_new_block?).at_least(:once).and_return(true)
      end

      it "removes steps not included in the create journey" do
        expect(workflow.steps).to eq([
          Workflow::Step.new(:edit_draft, :edit_draft, :update_draft, true),
          Workflow::Step.new(:group_my_group, :group_my_group, :redirect_to_next_step, true),
          Workflow::Step.new(:embedded_ungrouped, :embedded_ungrouped, :redirect_to_next_step, true),
          Workflow::Step.new(:review, :review, :complete_workflow, true),
          Workflow::Step.new(:confirmation, :confirmation, nil, true),
        ].flatten)
      end

      describe "#next_step" do
        [
          %i[edit_draft group_my_group],
          %i[group_my_group embedded_ungrouped],
          %i[embedded_ungrouped review],
          %i[review confirmation],
        ].each do |current_step, expected_step|
          describe "when current_step is #{current_step}" do
            let(:step) { current_step }

            it "returns #{expected_step} step" do
              expect(expected_step).to eq(workflow.next_step.name)
            end
          end
        end
      end

      describe "#previous_step" do
        [
          %i[group_my_group edit_draft],
          %i[embedded_ungrouped group_my_group],
          %i[review embedded_ungrouped],
        ].each do |current_step, expected_step|
          describe "when current_step is #{current_step}" do
            let(:step) { current_step }

            it "returns #{expected_step} step" do
              expect(expected_step).to eq(workflow.previous_step.name)
            end
          end
        end
      end
    end
  end

  describe "when an unknown step name is provided" do
    let(:step) { "something_unknown" }

    describe "#current_step" do
      it "raises an error" do
        assert_raises(Workflow::HasSteps::UnknownStepError) { workflow.current_step }
      end
    end

    describe "#next_step" do
      it "raises an error" do
        assert_raises(Workflow::HasSteps::UnknownStepError) { workflow.next_step }
      end
    end

    describe "#previous_step" do
      it "raises an error" do
        assert_raises(Workflow::HasSteps::UnknownStepError) { workflow.previous_step }
      end
    end
  end
end
