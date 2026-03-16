RSpec.shared_examples "an outcome" do |event_scope:|
  let(:skipped) { false }
  let(:performer) { "Someone" }
  let(:outcome) { build(described_class.name.underscore.to_sym, skipped:, performer:) }

  def self.it_creates_a_domain_event_when_saved
    it "creates a domain event when the outcome is saved" do
      expect { outcome.save! }.to change { DomainEvent.count }.by(1)

      domain_event = DomainEvent.last
      expect(domain_event.document).to eq(outcome.edition.document)
      expect(domain_event.user).to eq(outcome.creator)
      expect(domain_event.name).to eq("edition.#{outcome.event_scope}.#{outcome.result}")
      expect(domain_event.edition).to eq(outcome.edition)
      expect(domain_event.version).to eq(outcome.edition.versions.last)
    end
  end

  describe "#result" do
    context "when the outcome is skipped" do
      let(:skipped) { true }

      it "returns performed" do
        expect(outcome.result).to eq("skipped")
      end
    end

    context "when the outcome is not skipped" do
      let(:skipped) { false }

      it "returns performed" do
        expect(outcome.result).to eq("performed")
      end
    end
  end

  describe "#event_scope" do
    it "returns the correct event scope" do
      expect(outcome.event_scope).to eq(event_scope)
    end
  end

  describe "callbacks" do
    context "when the outcome is skipped" do
      let(:skipped) { true }

      it_creates_a_domain_event_when_saved

      it "does not record any metadata" do
        outcome.save!

        domain_event = DomainEvent.last
        expect(domain_event.metadata).to eq({})
      end
    end

    context "when the outcome is not skipped" do
      let(:skipped) { false }

      it_creates_a_domain_event_when_saved

      it "records the performer in the metadata" do
        outcome.save!

        domain_event = DomainEvent.last
        expect(domain_event.metadata).to eq({ "performer" => performer })
      end
    end
  end
end
