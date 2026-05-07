RSpec.describe "Pages", type: :request do
  before do
    logout
    user = create(:user)
    login_as(user)
  end
  describe "GET /accessibility_statement" do
    it "returns http success" do
      get "/accessibility-statement"
      expect(response).to have_http_status(:success)
    end
  end
end
