require "test_helper"

class Edition::WorkflowTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "transitions" do
    it "sets draft as the default state" do
      edition = create(:edition, document: create(:document, block_type: "pension"))
      assert edition.draft?
    end

    it "transitions a scheduled edition into the published state when publishing" do
      edition = create(:edition,
                       document: create(
                         :document,
                         block_type: "pension",
                       ),
                       scheduled_publication: 7.days.since(Time.zone.now).to_date,
                       state: "scheduled")
      edition.publish!
      assert edition.published?
    end

    it "transitions into the scheduled state when scheduling" do
      edition = create(:edition,
                       scheduled_publication: 7.days.since(Time.zone.now).to_date,
                       document: create(
                         :document,
                         block_type: "pension",
                       ))
      edition.schedule!
      assert edition.scheduled?
    end

    it "transitions into the superseded state when superseding" do
      edition = create(:edition, :pension, scheduled_publication: 7.days.since(Time.zone.now).to_date, state: "scheduled")
      edition.supersede!
      assert edition.superseded?
    end
  end

  describe "validation" do
    let(:document) { build(:document) }
    let(:edition) { build(:edition, document: document) }

    it "validates when the state is scheduled" do
      ScheduledPublicationValidator.any_instance.expects(:validate)

      edition.state = "scheduled"
      edition.valid?
    end

    it "does not validate when the state is not scheduled" do
      ScheduledPublicationValidator.any_instance.expects(:validate).never

      edition.state = "draft"
      edition.valid?
    end

    it "validates when the validation scope is set to scheduling" do
      ScheduledPublicationValidator.any_instance.expects(:validate)

      edition.state = "draft"
      edition.valid?(:scheduling)
    end
  end
end
