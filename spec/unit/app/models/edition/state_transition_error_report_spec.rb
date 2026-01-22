RSpec.describe Edition::StateTransitionErrorReport do
  describe "#call" do
    let(:document) { build(:document, id: 111) }
    let(:edition) { build(:edition, id: 999, document: document) }
    let(:error_message) { "This transition failed" }
    let(:error) { double("Error", message: error_message) }

    before do
      allow(GovukError).to receive(:notify)
      described_class.new(error: error, edition: edition).call
    end

    describe "sends error to Sentry via GovukError" do
      it "records the error" do
        expect(GovukError).to have_received(:notify).with(
          error,
          anything,
        )
      end

      it "records the edition's ID" do
        expect(GovukError).to have_received(:notify).with(
          anything,
          hash_including(
            extra: hash_including(
              edition_id: 999,
            ),
          ),
        )
      end

      it "records the associated document's ID" do
        expect(GovukError).to have_received(:notify).with(
          anything,
          hash_including(
            extra: hash_including(
              document_id: 111,
            ),
          ),
        )
      end

      it "sets the error 'level' to 'warn'" do
        expect(GovukError).to have_received(:notify).with(
          anything,
          hash_including(
            level: :warn,
          ),
        )
      end
    end
  end
end
