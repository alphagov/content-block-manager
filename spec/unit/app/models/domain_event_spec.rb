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
end
