RSpec.describe Edition::StateTransitionMessage do
  describe "#to_s" do
    let(:given_state) { "given_state" }
    let(:transition_message) { "translated state transition message" }
    let(:document) { create(:document) }
    let(:first_edition) { create(:edition, :published, document: document) }

    before { allow(I18n).to receive(:t).and_return(transition_message) }

    context "when given a *first* edition" do
      let(:message) { described_class.new(edition: first_edition, state: given_state) }

      it "asks I18n for the 'transition_message' for the given state of a first edition" do
        message.to_s

        expect(I18n).to have_received(:t).with("edition.states.transition_message.first.#{given_state}")
      end

      it "returns the translation provided by I18n" do
        expect(message.to_s).to eq(transition_message)
      end
    end

    context "when given a *further* edition" do
      let(:further_edition) do
        first_edition
        create(:edition, :draft, document: document)
      end

      let(:message) { described_class.new(edition: further_edition, state: given_state) }

      it "asks I18n for the 'transition_message' for the given state of a further edition" do
        message.to_s

        expect(I18n).to have_received(:t).with("edition.states.transition_message.further.#{given_state}")
      end

      it "returns the translation provided by I18n" do
        expect(message.to_s).to eq(transition_message)
      end
    end
  end
end
