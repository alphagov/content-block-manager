RSpec.describe "V2 documents routing", type: :routing do
  describe "V2 Documents controller" do
    before do
      FactoryBot.create(:v2_document, id: 1234)
    end

    it "routes '/v2/documents' to 'v2/documents#index'" do
      expect(get: "/v2/documents").to route_to("v2/documents#index")
    end

    it "routes '/v2/documents/:id' to 'v2/documents#show'" do
      expect(get: "/v2/documents/1234").to route_to("v2/documents#show", id: "1234")
    end
  end
end
