RSpec.describe PublishedEditionController, type: :controller do
  let(:schema) { double("schema") }
  let(:document) { instance_double(Document, block_type: "pension") }
  let(:latest_edition) { instance_double(Edition) }
  let(:versions) { double("versions") }
  let(:host_content_items) { double("host_content_items") }

  before do
    allow(Document).to receive(:find).and_return(document)
    allow(document).to receive(:latest_published_edition).and_return(latest_edition)
    allow(document).to receive(:versions).and_return(versions)
    allow(Schema).to receive(:find_by_block_type).and_return(schema)
    allow(schema).to receive(:subschemas).and_return([])
    allow(HostContentItem).to receive(:for_document).and_return(host_content_items)
  end

  describe "GET to :show" do
    before { get :show, params: { id: 123, order: "-last_edited_at", page: "2" } }

    it "finds the given document and assigns to @document" do
      expect(Document).to have_received(:find).with("123")
      expect(assigns(:document)).to eq(document)
    end

    it "finds the latest_published_edition and assigns to @edition" do
      expect(document).to have_received(:latest_published_edition)
      expect(assigns(:edition)).to eq(latest_edition)
    end

    it "finds the schema and assigns to @schema" do
      expect(document).to have_received(:block_type)
      expect(assigns(:schema)).to eq(schema)
    end

    it "find the document versions and assigns them to @content_block_versions" do
      expect(assigns(:content_block_versions)).to eq(versions)
    end

    it "finds host content items and assigns them to @host_content_items" do
      expect(HostContentItem).to have_received(:for_document).with(
        document,
        order: "-last_edited_at",
        page: "2",
      )
      expect(assigns(:host_content_items)).to eq(host_content_items)
    end

    it "renders the documents/show template" do
      expect(response).to have_rendered("documents/show")
    end
  end
end
