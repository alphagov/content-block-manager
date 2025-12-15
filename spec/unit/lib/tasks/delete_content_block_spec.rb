RSpec.describe Rake::Task["delete_content_block"] do
  let(:content_id) { SecureRandom.uuid }

  after do
    described_class.reenable
  end

  describe "when a content block exists" do
    let!(:document) { create(:document, :pension, content_id:) }
    let!(:editions) { create_list(:edition, 5, document: document) }

    it "returns an error if the document has host content" do
      stub_response = double("HostContentItem::Items", items: double(count: 2))
      allow(HostContentItem).to receive(:for_document).with(document).and_return(stub_response)

      expect {
        described_class.invoke(content_id)
      }.to raise_error(SystemExit, "Content block `#{content_id}` cannot be deleted because it has host content. Try removing the dependencies and trying again")

      document.reload

      expect(document.soft_deleted?).to be(false)
    end

    describe "when the document does not have host content" do
      before do
        stub_response = double("HostContentItem::Items", items: double(count: 0))
        allow(HostContentItem).to receive(:for_document).with(document).and_return(stub_response)
        allow(Document).to receive(:find_by).with(content_id:).and_return(document)
      end

      it "destroys the content block" do
        allow(Services.publishing_api).to receive(:unpublish).with(
          content_id,
          type: "vanish",
          locale: "en",
          discard_drafts: true,
        )

        described_class.invoke(content_id)

        document.reload

        expect(document.soft_deleted?).to be(true)
      end
    end
  end

  it "returns an error if the content block cannot be found" do
    expect {
      described_class.invoke(content_id)
    }.to raise_error(SystemExit, "A content block with the content ID `#{content_id}` cannot be found")
  end
end
