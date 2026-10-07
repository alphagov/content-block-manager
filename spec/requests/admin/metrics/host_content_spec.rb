RSpec.describe Admin::Metrics::HostContentController, type: :request do
  include Rails.application.routes.url_helpers

  describe "GET #index" do
    describe "when the user has the view_metrics permission" do
      let(:user) { create(:user, permissions: [User::Permissions::SIGNIN, User::Permissions::VIEW_METRICS]) }

      before { login_as(user) }

      it "shows the host content metrics page" do
        get admin_metrics_host_content_path

        expect(response).to have_http_status(:ok)
        expect(Capybara.string(response.body)).to have_css("h1", text: "Host content metrics")
      end

      it "shows that the page is one of the metrics pages" do
        get admin_metrics_host_content_path

        expect(Capybara.string(response.body)).to have_css(".gem-c-heading__context", text: "Metrics")
      end
    end

    describe "when the user doesn't have the view_metrics permission" do
      let(:user) { create(:user, permissions: [User::Permissions::SIGNIN]) }

      before { login_as(user) }

      it "shows the app's permissions error page" do
        get admin_metrics_host_content_path

        expect(response).to have_http_status(:forbidden)
        expect(Capybara.string(response.body)).to have_css("h1", text: "Permissions error")
      end
    end
  end
end
