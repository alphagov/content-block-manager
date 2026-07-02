RSpec.describe Api::ResultsPresenter do
  describe ".present" do
    let(:blocks) { [double("block")] }
    let(:result) { double(blocks: blocks) }
    subject { described_class.present(result) }

    before do
      allow(Api::BlockPresenter).to receive(:present_collection).with(blocks).and_return([:presented])
    end

    it "returns only presented results" do
      expect(subject).to eq({ results: [:presented] })
    end
  end
end
