RSpec.describe Edition::Workflow, type: :model do
  let(:version) { double("version") }
  let(:ar_association) { double("association", create!: version) }

  before do
    allow_any_instance_of(Edition).to receive(:versions).and_return(ar_association)
    allow(DomainEvent).to receive(:record)
  end

  describe "use of state machine's 'event_fired' callback" do
    let(:user) { create("user") }

    describe "creation of a new _version_ on state transition" do
      let(:user) { build(:user, id: 456) }
      let(:document) { build(:document, id: 10) }
      let(:edition) { build(:edition, id: 123, document: document) }
      let(:diffs) { double("field_diffs") }
      let(:ar_association) { double("association", create!: version) }

      before do
        allow(edition.versions).to receive(:create)
        allow(edition).to receive(:versions).and_return(ar_association)
      end

      context "when the transition succeeds" do
        before do
          allow(Current).to receive(:user).and_return(user)
          allow(edition).to receive(:generate_diff).and_return(diffs)
          allow(edition).to receive(:record_create)
          allow(DomainEvent).to receive(:create)

          edition.state = :draft

          edition.complete_draft!
        end

        it "sets the state of the new version to the destination state of the transition" do
          expect(ar_association).to have_received(:create!).with(
            hash_including(
              state: :draft_complete,
            ),
          )
        end

        it "associates the current User with the version" do
          expect(ar_association).to have_received(:create!).with(
            hash_including(
              user: user,
            ),
          )
        end

        it "sets Version#field_diffs to any generated diffs" do
          expect(ar_association).to have_received(:create!).with(
            hash_including(
              field_diffs: diffs,
            ),
          )
        end

        it "sets the Version#event to 'updated'" do
          expect(ar_association).to have_received(:create!).with(
            hash_including(
              event: "updated",
            ),
          )
        end
      end

      context "when the transition fails" do
        before do
          allow(edition).to receive(:publish!).and_raise(Transitions::InvalidTransition)
          edition.publish!
        rescue Transitions::InvalidTransition
          # we're interested in whether a version is created after the error is handled
        end

        it "does NOT create a Version for the transition" do
          expect(ar_association).not_to have_received(:create!)
        end
      end
    end

    describe "recording domain events" do
      let(:document) { build(:document) }
      let(:edition) { create(:edition, :draft_complete, document: document) }
      let(:user) { build(:user) }

      before do
        allow(DomainEvent).to receive(:record)
      end

      context "when the transition fails" do
        before do
          allow(edition).to receive(:publish!).and_raise(Transitions::InvalidTransition)
          edition.publish!
        rescue Transitions::InvalidTransition
          # we're interested in whether an event is created after the error is handled
        end

        it "does NOT create a Domain Event for the transition" do
          expect(DomainEvent).not_to have_received(:record)
        end
      end

      context "when a transition completes successfully" do
        let(:expected_transition_description) do
          {
            previous_state: :draft_complete,
            new_state: :awaiting_review,
            transition_name: :ready_for_review,
          }
        end

        before do
          allow(Current).to receive(:user).and_return(user)

          edition.ready_for_review!
        end

        it "asks DomainEvent::record to record the transition" do
          expect(DomainEvent).to have_received(:record).with(
            name: "edition.state_transition.succeeded",
            metadata: expected_transition_description,
            edition: edition,
            document: document,
            user: user,
            version: version,
          )
        end
      end
    end
  end

  describe "transitions" do
    it "sets draft as the default state" do
      edition = create(:edition, document: create(:document, block_type: "pension"))
      expect(edition).to be_draft
    end

    describe "transition to 'draft_complete' state" do
      let(:edition) { create(:edition, :pension, :draft) }

      context "when in the 'draft' state" do
        it "is permitted" do
          edition.complete_draft!

          expect(edition.draft_complete?).to be true
        end
      end

      (Edition.available_states - [:draft]).each do |state|
        context "when in non draft state '#{state}'" do
          before { edition.state = state }

          it "does NOT allow the #complete_draft! transition" do
            expect { edition.complete_draft! }.to raise_error(Transitions::InvalidTransition)
          end
        end
      end
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

      Edition.in_progress_states.each do |state|
        context "when in the in-progress state '#{state}'" do
          before { edition.state = state }

          it "allows the #publish! transition" do
            expect(edition.publish!).to be true
          end
        end
      end

      Edition.finalised_states.each do |state|
        context "when in finalised state '#{state}'" do
          before { edition.state = state }

          it "does NOT allow the #publish! transition" do
            expect { edition.publish! }.to raise_error(Transitions::InvalidTransition)
          end
        end
      end
    end

    it "transitions into the scheduled state when scheduling" do
      edition = create(:edition,
                       scheduled_publication: 7.days.since(Time.zone.now).to_date,
                       state: :awaiting_factcheck,
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

    describe "transitions into the awaiting_review state with #ready_for_review!" do
      context "when in the 'draft_complete' state" do
        let(:edition) { create(:edition, :pension, :draft_complete) }

        it "allows the transition" do
          expect(edition.ready_for_review!).to be true
        end
      end

      context "when in the 'scheduled' state" do
        let(:edition) do
          create(:edition, :pension, state: :scheduled, scheduled_publication: 1.week.from_now)
        end

        it "is NOT permitted" do
          expect { edition.ready_for_review }.to raise_error(
            Transitions::InvalidTransition,
          )
        end
      end

      (Edition.available_states - %i[draft_complete scheduled]).each do |state|
        context "when in the '#{state}' state" do
          let(:edition) { create(:edition, :pension, state: state) }

          it "is NOT permitted" do
            expect { edition.ready_for_review }.to raise_error(
              Transitions::InvalidTransition,
            )
          end
        end
      end
    end

    describe "transition to 'awaiting_factcheck' state" do
      let(:edition) { create(:edition, :pension, :draft) }
      let!(:current_user) { create(:user) }
      let(:review_outcome) { instance_double(ReviewOutcome) }

      context "when in the 'awaiting_review' state" do
        before { edition.state = "awaiting_review" }

        context "when a Review outcome has been recorded" do
          before { allow(edition).to receive(:review_outcome).and_return(review_outcome) }

          it "allows the #ready_for_factcheck! transition" do
            expect(edition.ready_for_factcheck!).to be true
          end
        end

        context "when a Review outcome has NOT been recorded" do
          it "raises a ReviewOutcomeMissingError" do
            expect { edition.ready_for_factcheck! }.to raise_error(
              Edition::Workflow::ReviewOutcomeMissingError,
              /Edition #{edition.id} does not have a 2i Review outcome recorded/,
            )
          end
        end
      end

      (Edition.available_states - [:awaiting_review]).each do |state|
        context "when in the '#{state}' state" do
          before { edition.state = state }

          it "does NOT allow the 'ready_for_factcheck! transition" do
            expect { edition.ready_for_factcheck! }.to raise_error(Transitions::InvalidTransition)
          end
        end
      end
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

  # Using Edition.available_states here to ensure that any new states added in the future are included automatically
  # and these tests will fail, forcing the user to decide whether the new state is in-progress or not.
  describe "#in_progress" do
    (Edition.available_states - %i[superseded published deleted]).each do |state|
      context "when the edition is in an in-progress state (#{state})" do
        it "returns true" do
          edition = build(:edition, state: state)
          expect(edition.in_progress?).to be(true)
        end
      end
    end

    (Edition.available_states - %i[draft draft_complete awaiting_review awaiting_factcheck scheduled]).each do |state|
      context "when the edition is NOT in an in-progress state (#{state})" do
        it "returns true" do
          edition = build(:edition, state: state)
          expect(edition.in_progress?).to be(false)
        end
      end
    end
  end
end
