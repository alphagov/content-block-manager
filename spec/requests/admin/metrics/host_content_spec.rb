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

      describe "with blocks from two organisations" do
        before do
          allow(Organisation).to receive(:all).and_return([])
          create(:edition, :pension, :published, title: "Zebra block").document.tap do |document|
            create(:rollup_metric, document:, views: 1_000, lead_organisation_name: "Zebra Office")
          end
          create(:edition, :pension, :published, title: "Aardvark block").document.tap do |document|
            create(:rollup_metric, document:, views: 10, lead_organisation_name: "Aardvark Agency")
          end
        end

        def body
          Capybara.string(response.body)
        end

        def titles
          body.all("[data-testid='host_content_metrics_table'] tbody tr td:nth-child(2)")
              .map { |cell| cell.text.strip }
        end

        it "sorts by views, highest first, by default" do
          get admin_metrics_host_content_path

          expect(titles).to eq(["Zebra block", "Aardvark block"])
        end

        it "sorts by organisation when asked to" do
          get admin_metrics_host_content_path(order: "lead_organisation_name")

          expect(titles).to eq(["Aardvark block", "Zebra block"])
        end

        it "ignores an order it doesn't allow" do
          get admin_metrics_host_content_path(order: "title; DROP TABLE documents")

          expect(response).to have_http_status(:ok)
          expect(titles).to eq(["Zebra block", "Aardvark block"])
        end

        describe "one block per page" do
          before { stub_const("Document::RollupMetricsQuery::PER_PAGE", 1) }

          it "shows one page of blocks at a time" do
            get admin_metrics_host_content_path(page: 2)

            expect(titles).to eq(["Aardvark block"])
          end

          it "keeps the current order when moving to the next page" do
            get admin_metrics_host_content_path(order: "lead_organisation_name")
            expect(titles).to eq(["Aardvark block"])

            get body.find(".govuk-pagination__next a")[:href]

            expect(titles).to eq(["Zebra block"])
          end
        end
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
