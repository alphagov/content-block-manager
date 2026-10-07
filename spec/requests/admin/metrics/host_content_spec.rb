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

      it "lists every block that hasn't been deleted, including drafts" do
        allow(Organisation).to receive(:all).and_return([])
        create(:edition, :pension, :published, title: "New state pension")
        create(:edition, :contact, :draft, title: "CMA press office")
        create(:edition, :pension, :published, title: "Deleted pension").document.soft_delete

        get admin_metrics_host_content_path

        table = Capybara.string(response.body).find("[data-testid='host_content_metrics_table']")
        expect(table).to have_css("tbody tr", count: 2)
        expect(table).to have_text("New state pension")
        expect(table).to have_text("CMA press office")
        expect(table).not_to have_text("Deleted pension")
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
