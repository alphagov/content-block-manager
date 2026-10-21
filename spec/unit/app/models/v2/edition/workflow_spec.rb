RSpec.describe V2::Edition::Workflow, type: :model do
  let(:version) { double("version") }

  before do
    allow(V2::Version).to receive(:increment_for_edition).and_return(version)
    allow(V2::DomainEvent).to receive(:record)
  end

  describe "use of state machine's 'event_fired' callback" do
    let(:user) { create("user") }

    describe "creation of a new _version_ on state transition" do
      let(:user) { build(:user, id: 456) }
      let(:document) { build(:v2_document, id: 10) }
      let(:edition) { build(:v2_edition, id: 123, document: document) }
      let(:diffs) { double("field_diffs") }

      context "when the transition succeeds" do
        before do
          allow(Current).to receive(:user).and_return(user)
          allow(edition).to receive(:generate_diff).and_return(diffs)

          edition.state = :draft

          edition.publish!
        end

        it "asks V2::Version::increment_for_edition to create a new version" do
          expect(V2::Version).to have_received(:increment_for_edition).with(
            edition: edition,
            user: user,
            field_diffs: diffs,
            state: :published,
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

        it "does NOT create a V2::Version for the transition" do
          expect(V2::Version).not_to have_received(:increment_for_edition)
        end
      end
    end

    describe "recording domain events" do
      let(:document) { build(:v2_document) }
      let(:edition) { create(:v2_edition, :draft, document: document) }
      let(:user) { build(:user) }

      before do
        allow(V2::DomainEvent).to receive(:record)
      end

      context "when the transition fails" do
        before do
          allow(edition).to receive(:publish!).and_raise(Transitions::InvalidTransition)
          edition.publish!
        rescue Transitions::InvalidTransition
          # we're interested in whether an event is created after the error is handled
        end

        it "does NOT create a Domain Event for the transition" do
          expect(V2::DomainEvent).not_to have_received(:record)
        end
      end

      context "when a transition completes successfully" do
        let(:expected_transition_description) do
          {
            previous_state: :draft,
            new_state: :published,
            transition_name: :publish,
          }
        end

        before do
          allow(Current).to receive(:user).and_return(user)

          edition.publish!
        end

        it "asks V2::DomainEvent::record to record the transition" do
          expect(V2::DomainEvent).to have_received(:record).with(
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
      edition = create(:v2_edition, document: create(:v2_document))
      expect(edition).to be_draft
    end

    describe "transition to 'published' state" do
      let(:edition) { create(:v2_edition) }

      context "when in 'draft' state" do
        before do
          edition.state = "draft"
        end

        it "transitions into the published state" do
          edition.publish!
          expect(edition).to be_published
        end
      end

      V2::Edition.in_progress_states.each do |state|
        context "when in the in-progress state '#{state}'" do
          before { edition.state = state }

          it "allows the #publish! transition" do
            expect(edition.publish!).to be true
          end
        end
      end

      V2::Edition.finalised_states.each do |state|
        context "when in finalised state '#{state}'" do
          before { edition.state = state }

          it "does NOT allow the #publish! transition" do
            expect { edition.publish! }.to raise_error(Transitions::InvalidTransition)
          end
        end
      end
    end

    describe "translations for status tag" do
      it "finds a status for each state's tag" do
        aggregate_failures do
          V2::Edition.new.available_states.each do |state|
            expect(I18n.t("edition.states.label.#{state}"))
              .not_to match(/Translation missing/),
                      "Translation not found for tag status for state '#{state}'"
          end
        end
      end
    end
  end

  # Using V2::Edition.available_states here to ensure that any new states added in the future are included automatically
  # and these tests will fail, forcing the user to decide whether the new state is in-progress or not.
  describe "#in_progress" do
    (V2::Edition.available_states - %i[superseded published deleted]).each do |state|
      context "when the edition is in an in-progress state (#{state})" do
        it "returns true" do
          edition = build(:edition, state: state)
          expect(edition.in_progress?).to be(true)
        end
      end
    end

    (V2::Edition.available_states - %i[draft draft_complete awaiting_review awaiting_factcheck scheduled]).each do |state|
      context "when the edition is NOT in an in-progress state (#{state})" do
        it "returns true" do
          edition = build(:edition, state: state)
          expect(edition.in_progress?).to be(false)
        end
      end
    end
  end
end
