RSpec.describe Api::ResultsPresenter do
  describe "#present" do
    let(:blocks) { [double("block")] }

    before do
      allow(Api::BlockPresenter).to receive(:present_collection).with(blocks).and_return([:presented])
    end

    context "on the first page" do
      let(:result) { double(total_count: 10, total_pages: 3, current_page: 1, blocks: blocks) }
      let(:request_url) { "https://example.com/api/blocks?foo=bar&page=1" }
      subject { described_class.present(result, request_url) }

      it "includes pagination fields and results" do
        expect(subject).to include(total: 10, pages: 3, current_page: 1)
        expect(subject[:results]).to eq([:presented])
      end

      it "includes next and self links (no previous)" do
        links = subject[:links]
        expect(links.map { |l| l[:rel] }).to eq(%w[next self])

        next_link = links.find { |l| l[:rel] == "next" }
        self_link = links.find { |l| l[:rel] == "self" }

        expect(next_link[:href]).to eq("https://example.com/api/blocks?foo=bar&page=2")
        expect(self_link[:href]).to eq("https://example.com/api/blocks?foo=bar&page=1")
      end
    end

    context "on a middle page" do
      let(:result) { double(total_count: 10, total_pages: 3, current_page: 2, blocks: blocks) }
      let(:request_url) { "https://example.com/api/blocks?foo=bar&page=2" }
      subject { described_class.present(result, request_url) }

      it "includes previous, next and self links in that order" do
        rels = subject[:links].map { |l| l[:rel] }
        expect(rels).to eq(%w[previous next self])

        prev = subject[:links].find { |l| l[:rel] == "previous" }
        nxt = subject[:links].find { |l| l[:rel] == "next" }

        expect(prev[:href]).to eq("https://example.com/api/blocks?foo=bar&page=1")
        expect(nxt[:href]).to eq("https://example.com/api/blocks?foo=bar&page=3")
      end
    end

    context "on the last page" do
      let(:result) { double(total_count: 10, total_pages: 3, current_page: 3, blocks: blocks) }
      let(:request_url) { "https://example.com/api/blocks?foo=bar&page=3" }
      subject { described_class.present(result, request_url) }

      it "includes previous and self links (no next)" do
        rels = subject[:links].map { |l| l[:rel] }
        expect(rels).to eq(%w[previous self])

        prev = subject[:links].find { |l| l[:rel] == "previous" }
        self_link = subject[:links].find { |l| l[:rel] == "self" }

        expect(prev[:href]).to eq("https://example.com/api/blocks?foo=bar&page=2")
        expect(self_link[:href]).to eq("https://example.com/api/blocks?foo=bar&page=3")
      end
    end

    context "when request_url has no page param" do
      let(:result) { double(total_count: 10, total_pages: 3, current_page: 1, blocks: blocks) }
      let(:request_url) { "https://example.com/api/blocks?foo=bar" }
      subject { described_class.present(result, request_url) }

      it "appends page param with an ampersand" do
        rels = subject[:links].map { |l| l[:rel] }
        expect(rels).to eq(%w[next self])

        expect(subject[:links].find { |l| l[:rel] == "next" }[:href]).to eq("https://example.com/api/blocks?foo=bar&page=2")
        expect(subject[:links].find { |l| l[:rel] == "self" }[:href]).to eq("https://example.com/api/blocks?foo=bar&page=1")
      end
    end

    context "when there is only one page" do
      let(:result) { double(total_count: 2, total_pages: 1, current_page: 1, blocks: blocks) }
      let(:request_url) { "https://example.com/api/blocks?foo=bar&page=1" }
      subject { described_class.present(result, request_url) }

      it "only exposes the self link" do
        rels = subject[:links].map { |l| l[:rel] }
        expect(rels).to eq(%w[self])
        expect(subject[:links].first[:href]).to eq("https://example.com/api/blocks?foo=bar&page=1")
      end
    end
  end
end
