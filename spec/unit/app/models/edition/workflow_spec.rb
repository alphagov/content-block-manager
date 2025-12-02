RSpec.describe Edition::Workflow, type: :model do
  describe "transitions" do
    it "sets draft as the default state" do
      edition = create(:edition, document: create(:document, block_type: "pension"))
      expect(edition).to be_draft
    end

    context "when transitioning to published" do
      it "transitions from scheduled into a published state" do
        edition = create(:edition,
                         document: create(
                           :document,
                           block_type: "pension",
                         ),
                         scheduled_publication: 7.days.since(Time.zone.now).to_date,
                         state: "scheduled")
        edition.publish!
        expect(edition).to be_published
      end
    end

    context "when transitioning to scheduled" do
      it "transitions from draft into a scheduled state" do
        edition = create(:edition,
                         scheduled_publication: 7.days.since(Time.zone.now).to_date,
                         document: create(
                           :document,
                           block_type: "pension",
                         ))
        edition.schedule!
        expect(edition).to be_scheduled
      end
    end

    context "when transitioning to superseded" do
      it "transitions from scheduled into a superseded state" do
        edition = create(:edition, :pension, scheduled_publication: 7.days.since(Time.zone.now).to_date, state: "scheduled")
        edition.supersede!
        expect(edition).to be_superseded
      end
    end

    context "when transitioning to awaiting_2i" do
      it "transitions from draft into an awaiting_2i state" do
        edition = create(:edition, document: create(:document, block_type: "pension"))
        edition.ready_for_2i!
        assert edition.awaiting_2i?
      end
    end

    context "when transitioning to deleted" do
      it "transitions from draft into a deleted state" do
        edition = create(:edition, document: create(:document, block_type: "pension"))
        edition.delete!
        assert edition.deleted?
      end

      it "calls the DeleteEditionService on successful transition" do
        edition = create(:edition, document: create(:document, block_type: "pension"))
        delete_service_mock = spy
        allow(DeleteEditionService).to receive(:new).and_return(delete_service_mock)

        edition.delete!

        expect(delete_service_mock).to have_received(:call).with(edition)
      end

      it "doesn't call the DeleteEditionService on failed transition" do
        edition = create(:edition, document: create(:document, block_type: "pension"), state: "published")
        delete_service_mock = spy
        allow(DeleteEditionService).to receive(:new).and_return(delete_service_mock)

        expect { edition.delete! }.to raise_error(Transitions::InvalidTransition)

        expect(delete_service_mock).not_to have_received(:call)
      end
    end

    describe "translations for status tag" do
      it "finds a status for each state's tag" do
        aggregate_failures do
          Edition.new.available_states.each do |state|
            expect(I18n.t("edition.states.label.#{state}"))
              .not_to match(/Translation missing/),
                      "Translation not found for tag status for state '#{state}'"
          end
        end
      end
    end
  end

  describe "validation" do
    let(:document) { build(:document) }
    let(:edition) { build(:edition, document: document) }

    it "validates when the state is scheduled" do
      expect_any_instance_of(ScheduledPublicationValidator).to receive(:validate)

      edition.state = "scheduled"
      edition.valid?
    end

    it "does not validate when the state is not scheduled" do
      expect_any_instance_of(ScheduledPublicationValidator).not_to receive(:validate)

      edition.state = "draft"
      edition.valid?
    end

    it "validates when the validation scope is set to scheduling" do
      expect_any_instance_of(ScheduledPublicationValidator).to receive(:validate)

      edition.state = "draft"
      edition.valid?(:scheduling)
    end
  end
end
