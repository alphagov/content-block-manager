RSpec.describe Edition::Workflow, type: :model do
  describe "transitions" do
    it "sets draft as the default state" do
      edition = create(:edition, document: create(:document, block_type: "pension"))
      expect(edition).to be_draft
    end

    describe "transition to 'published' state" do
      let(:edition) { create(:edition, :pension) }

      context "when in 'scheduled' state" do
        before do
          edition.scheduled_publication = 7.days.since(Time.zone.now).to_date
          edition.state = "scheduled"
        end

        it "transitions into the published state" do
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
    end

    it "transitions into the scheduled state when scheduling" do
      edition = create(:edition,
                       scheduled_publication: 7.days.since(Time.zone.now).to_date,
                       document: create(
                         :document,
                         block_type: "pension",
                       ))
      edition.schedule!
      expect(edition).to be_scheduled
    end

    it "transitions into the superseded state when superseding" do
      edition = create(:edition, :pension, scheduled_publication: 7.days.since(Time.zone.now).to_date, state: "scheduled")
      edition.supersede!
      expect(edition).to be_superseded
    end

    it "transitions into the awaiting_2i state when marking as ready for 2i" do
      edition = create(:edition, document: create(:document, block_type: "pension"))
      edition.ready_for_2i!
      assert edition.awaiting_2i?
    end

    it "transitions into the deleted state when marking as deleted" do
      edition = create(:edition, document: create(:document, block_type: "pension"))
      edition.delete!
      assert edition.deleted?
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
