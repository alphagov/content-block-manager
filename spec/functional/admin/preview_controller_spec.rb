RSpec.describe Admin::PreviewController, type: :request do
  include Rails.application.routes.url_helpers

  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  describe "POST #preview" do
    it "renders the body param using govspeak into a document body template" do
      post admin_preview_path, params: { body: "# gov speak" }

      fragment = Capybara.string(response.body)

      expect(fragment).to have_css(".document .body h1", text: "gov speak")
    end

    it "returns a 403 if the content contains potential XSS exploits" do
      post admin_preview_path, params: { body: "<script>alert('woah');</script>" }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
