RSpec.describe Edition::StateTransitionMessage do
  describe "#to_s" do
    let(:given_state) { "given_state" }
    let(:transition_message) { "translated state transition message" }
    let(:message) { described_class.new(state: given_state) }

    before { allow(I18n).to receive(:t).and_return(transition_message) }

    it "asks I18n for the 'transition_message' translation for the given state" do
      message.to_s

      expect(I18n).to have_received(:t).with("edition.states.transition_message.#{given_state}")
    end

    it "returns the translation provided by I18n" do
      expect(message.to_s).to eq(transition_message)
    end
  end
end
