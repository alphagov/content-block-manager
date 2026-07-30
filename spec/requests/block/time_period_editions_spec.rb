RSpec.describe "Block time period editions", type: :request do
  before do
    logout
    login_as(create(:user))
  end

  describe "GET /block/time_period_edition/:id" do
    it "renders the time period edition 'show' page" do
      get block_time_period_edition_path(0)

      expect(response).to have_http_status(:success)
      expect(response).to render_template("block/time_period_editions/show")
    end
  end

  describe "GET /block/time_period_editions/new" do
    before do
      allow(Organisation).to receive(:all).and_return([])
    end

    it "renders the new edition page" do
      get new_block_time_period_edition_path

      expect(response).to have_http_status(:success)
      expect(response).to render_template("block/time_period_editions/new")
    end
  end
end
