RSpec.describe DocumentsController, type: :request do
  let(:user) { create(:user) }

  describe "#index" do
    before do
      login_as(user)

      stub_request(:get, "http://publishing-api.dev.gov.uk/v2/content?document_type=organisation&fields%5B%5D=content_id&fields%5B%5D=title&per_page=500")
        .to_return(status: 200, body: '{"results": []}')
    end

    context "when called with no params" do
      before { get root_path }

      it "should return a redirect to itself with a blank lead_organisation" do
        expect(response.status).to eq(302)
        expect(response.headers["location"]).to eq("http://www.example.com/?lead_organisation=")
      end
    end

    context "when called with a blank lead_organisation" do
      before { get root_path(nil, params: { lead_organisation: "" }) }

      it "should return a 200 response" do
        expect(response.status).to eq(200)
      end
    end

    context "when called with a valid lead_organisation" do
      before { get root_path(nil, params: { lead_organisation: "4fdf37ba-17ed-41f4-9331-788e0126cd91" }) }

      it "should return a 200 response" do
        expect(response.status).to eq(200)
      end
    end
  end
end
