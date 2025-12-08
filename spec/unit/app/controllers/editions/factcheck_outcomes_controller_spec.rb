RSpec.describe Editions::FactcheckOutcomesController, type: :controller do
  let(:document) { Document.new(id: 456) }
  let(:edition) { Edition.new(id: 123, document: document) }

  before do
    allow(Edition).to receive(:find).and_return(edition)
  end

  describe "GET to :new" do
    before do
      get :new, params: { id: 123 }
    end

    it "sets the @edition variable to the given edition" do
      expect(Edition).to have_received(:find).with("123")
      expect(assigns(:edition)).to eq(edition)
    end

    it "sets the page title" do
      expect(assigns(:title)).to eq("Publish block")
    end

    it "renders the editions/factcheck_outcomes/new template" do
      expect(response).to have_rendered("editions/factcheck_outcomes/new")
    end
  end
end
