RSpec.describe "Block::TimePeriodEditions", type: :request do
  setup do
    logout
    user = create(:user)
    login_as(user)
  end

  let(:organisation) { build(:organisation, name: "Test Org") }

  before do
    allow(Organisation).to receive(:all).and_return([organisation])
  end

  describe "GET /block/time_period_editions/new" do
    it "returns http success" do
      get new_block_time_period_edition_path
      expect(response).to have_http_status(:success)
    end

    it "assigns a new edition with a new document" do
      get new_block_time_period_edition_path
      expect(assigns(:edition)).to be_a_new(Block::TimePeriodEdition)
      expect(assigns(:edition).document).to be_a_new(Block::Document)
      expect(assigns(:edition).document.block_type).to eq("time_period")
    end
  end

  describe "POST /block/time_period_editions" do
    let(:valid_attributes) do
      {
        edition: {
          title: "Tax Year 2025/26",
          description: "Current tax year",
          instructions_to_publishers: "Use this for tax year content",
          lead_organisation_id: organisation.id,
        },
      }
    end

    let(:invalid_attributes) do
      {
        edition: {
          title: "",
        },
      }
    end

    context "with valid parameters" do
      it "creates a new Block::TimePeriodEdition" do
        expect {
          post block_time_period_editions_path,
               params: valid_attributes
        }.to change(Block::TimePeriodEdition, :count).by(1)
      end

      it "creates a new Block::Document" do
        expect {
          post block_time_period_editions_path,
               params: valid_attributes
        }.to change(Block::Document, :count).by(1)
      end

      it "sets the document's sluggable_string from the title" do
        post block_time_period_editions_path,
             params: valid_attributes
        edition = Block::TimePeriodEdition.last
        expect(edition.document.sluggable_string).to eq("Tax Year 2025/26")
      end

      it "redirects to the created edition" do
        post block_time_period_editions_path,
             params: valid_attributes
        edition = Block::TimePeriodEdition.last
        expect(response).to redirect_to(
          block_time_period_edition_path(edition),
        )
      end
    end

    context "with invalid parameters" do
      it "does not create a new Block::TimePeriodEdition" do
        expect {
          post block_time_period_editions_path,
               params: invalid_attributes
        }.not_to change(Block::TimePeriodEdition, :count)
      end

      it "returns unprocessable entity status" do
        post block_time_period_editions_path,
             params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the new template" do
        post block_time_period_editions_path,
             params: invalid_attributes
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET /block/time_period_editions/:id" do
    let(:organisation) { build(:organisation) }
    let(:edition) { create(:time_period_edition, title: "Test Edition", lead_organisation_id: organisation.id) }

    it "returns http success" do
      get block_time_period_edition_path(edition)
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested edition" do
      get block_time_period_edition_path(edition)
      expect(assigns(:edition)).to eq(edition)
    end
  end
end
