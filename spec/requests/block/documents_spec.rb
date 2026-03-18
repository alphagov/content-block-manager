RSpec.describe "Block::Documents", type: :request do
  setup do
    logout
    user = create(:user)
    login_as(user)
  end

  let(:organisation) { build(:organisation, name: "Test Org") }

  before do
    allow(Organisation).to receive(:all).and_return([organisation])
    allow(Organisation).to receive(:find).and_return(organisation)
  end

  describe "GET /block/documents" do
    it "returns a successful response" do
      get block_documents_path
      expect(response).to have_http_status(:ok)
    end

    it "assigns editions from all documents" do
      document1 = create(:block_document, block_type: "time_period")
      document2 = create(:block_document, block_type: "time_period")
      edition1 = create(:time_period_edition, document: document1)
      edition2 = create(:time_period_edition, document: document2)

      get block_documents_path

      expect(response.body).to include(edition1.title)
      expect(response.body).to include(edition2.title)
    end
  end
end
