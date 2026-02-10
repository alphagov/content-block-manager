RSpec.describe DomainEvent, type: :model do
  it { is_expected.to belong_to(:document).required }
  it { is_expected.to belong_to(:user).required }
  it { is_expected.to belong_to(:edition).optional }
  it { is_expected.to belong_to(:version).optional }

  describe "#name" do
    let(:event) { DomainEvent.new }

    it "is required" do
      event.valid?

      expect(event.errors[:name]).to include("can't be blank")
    end

    context "when the name is in the list of permitted EVENT_NAMES" do
      before { event.name = DomainEvent::EVENT_NAMES.sample }

      it "is valid" do
        event.valid?

        expect(event.errors[:name]).to be_blank
      end
    end

    context "when the name is NOT in the list of permitted EVENT_NAMES" do
      before { event.name = "event.unknown" }

      it "is NOT valid" do
        event.valid?

        expect(event.errors[:name]).to include("not known")
      end
    end
  end

  describe "::record" do
    let(:document) { create(:document, id: 2) }
    let(:edition) { create(:edition, document: document) }
    let(:user) { create(:user) }
    let(:version) do
      Version.create!(
        item_type: "Edition",
        item_id: edition.id,
        event: "updated",
      )
    end

    let(:metadata) do
      {
        previous_state: :draft_complete,
        new_state: :awaiting_review,
        transition_name: :ready_for_review,
      }
    end

    let(:args) do
      {
        user: user,
        edition: edition,
        document: document,
        version: version,
        name: DomainEvent::EVENT_NAMES.first,
        metadata: metadata,
      }
    end

    let(:event) do
      DomainEvent.record(**args)
    end

    before do
      allow(Rails.logger).to receive(:info)
    end

    it("creates a DomainEvent with the given arguments") do
      aggregate_failures do
        expect(event.user_id).to eq(user.id)
        expect(event.edition_id).to eq(edition.id)
        expect(event.document_id).to eq(document.id)
        expect(event.version_id).to eq(version.id)
        expect(event.metadata.to_json).to eq(metadata.to_json)
      end
    end

    it "logs that an event has been created, to assist with any debugging" do
      expect(Rails.logger).to have_received(:info).with(
        "DomainEvent: recording #{event.inspect}",
      )
    end
  end
end
