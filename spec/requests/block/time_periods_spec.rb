RSpec.describe "Block::TimePeriods", type: :request do
  setup do
    logout
    user = create(:user)
    login_as(user)
  end

  describe "GET /block/time_periods/new" do
    it "returns http success" do
      get new_block_time_period_path
      expect(response).to have_http_status(:success)
    end

    it "assigns a new document and edition" do
      get new_block_time_period_path
      expect(assigns(:document)).to be_a_new(Block::Document)
      expect(assigns(:edition)).to be_a_new(Block::TimePeriodEdition)
    end
  end

  describe "POST /block/time_periods" do
    let(:valid_attributes) do
      {
        block_document: {
          sluggable_string: "tax-year-2025-26",
          block_type: "time_period",
        },
        block_time_period_edition: {
          title: "Tax Year 2025/26",
          description: "Current tax year",
          date_range_attributes: {
            start: "2025-04-06 00:00",
            end: "2026-04-05 23:59",
          },
        },
      }
    end

    let(:invalid_attributes) do
      {
        block_document: {
          sluggable_string: "",
          block_type: "time_period",
        },
        block_time_period_edition: {
          title: "",
        },
      }
    end

    context "with valid parameters" do
      it "creates a new Block::Document" do
        expect {
          post block_time_periods_path, params: valid_attributes
        }.to change(Block::Document, :count).by(1)
      end

      it "creates a new Block::TimePeriodEdition" do
        expect {
          post block_time_periods_path, params: valid_attributes
        }.to change(Block::TimePeriodEdition, :count).by(1)
      end

      it "creates a new Block::TimePeriodDateRange" do
        expect {
          post block_time_periods_path, params: valid_attributes
        }.to change(Block::TimePeriodDateRange, :count).by(1)
      end

      it "redirects to the created time period" do
        post block_time_periods_path, params: valid_attributes
        edition = Block::TimePeriodEdition.last
        expect(response).to redirect_to(block_time_period_path(edition))
      end

      it "sets a notice flash message" do
        post block_time_periods_path, params: valid_attributes
        expect(flash[:notice]).to eq("Time period was successfully created.")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Block::Document" do
        expect {
          post block_time_periods_path, params: invalid_attributes
        }.not_to change(Block::Document, :count)
      end

      it "returns unprocessable entity status" do
        post block_time_periods_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the new template" do
        post block_time_periods_path, params: invalid_attributes
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET /block/time_periods/:id" do
    let(:edition) { create(:time_period_edition) }

    it "returns http success" do
      get block_time_period_path(edition)
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested edition" do
      get block_time_period_path(edition)
      expect(assigns(:edition)).to eq(edition)
    end

    it "assigns the document" do
      get block_time_period_path(edition)
      expect(assigns(:document)).to eq(edition.document)
    end
  end

  describe "GET /block/time_periods/:id/edit" do
    let(:edition) { create(:time_period_edition) }

    it "returns http success" do
      get edit_block_time_period_path(edition)
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested edition" do
      get edit_block_time_period_path(edition)
      expect(assigns(:edition)).to eq(edition)
    end
  end

  describe "PATCH /block/time_periods/:id" do
    let(:edition) { create(:time_period_edition, title: "Old Title") }

    let(:valid_attributes) do
      {
        block_time_period_edition: {
          title: "New Title",
          description: "Updated description",
        },
      }
    end

    let(:invalid_attributes) do
      {
        block_time_period_edition: {
          title: "",
        },
      }
    end

    context "with valid parameters" do
      it "updates the requested edition" do
        patch block_time_period_path(edition), params: valid_attributes
        edition.reload
        expect(edition.title).to eq("New Title")
      end

      it "redirects to the edition" do
        patch block_time_period_path(edition), params: valid_attributes
        expect(response).to redirect_to(block_time_period_path(edition))
      end

      it "sets a notice flash message" do
        patch block_time_period_path(edition), params: valid_attributes
        expect(flash[:notice]).to eq("Time period was successfully updated.")
      end
    end

    context "with invalid parameters" do
      it "does not update the edition" do
        patch block_time_period_path(edition), params: invalid_attributes
        edition.reload
        expect(edition.title).to eq("Old Title")
      end

      it "returns unprocessable entity status" do
        patch block_time_period_path(edition), params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the edit template" do
        patch block_time_period_path(edition), params: invalid_attributes
        expect(response).to render_template(:edit)
      end
    end
  end
end
