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
    describe "when rendering the new template" do
      before do
        allow(Organisation).to receive(:all).and_return([])

        get new_block_time_period_edition_path
      end

      it "renders the correct page successfully" do
        expect(response).to have_http_status(:success)
        expect(response).to render_template("block/time_period_editions/new")
      end

      it "contains the correct form with the required fields" do
        expect(page).to have_css("form[action='#{block_time_period_editions_path}']") do |form|
          expect(form).to have_field("edition[title]")
          expect(form).to have_field("edition[description]")
          expect(form).to have_field("edition[lead_organisation_id]")
          expect(form).to have_field("edition[instructions_to_publishers]")
          expect(form).to have_button("Save and continue")
        end
      end

      it "contains character-limited fields with the correct character limits" do
        expect(page).to have_css(".govuk-character-count[data-module='govuk-character-count'][data-maxlength='65']")
        expect(page).to have_css(".govuk-character-count__message", text: "You can enter up to 65 characters")

        expect(page).to have_css(".govuk-character-count[data-module='govuk-character-count'][data-maxlength='165']")
        expect(page).to have_css(".govuk-character-count__message", text: "You can enter up to 165 characters")
      end

      it "initialises a time period edition with a time period document" do
        edition = assigns(:edition)

        expect(edition).to be_a(Block::TimePeriodEdition)
        expect(edition).to be_new_record
        expect(edition.document).to be_new_record
        expect(edition.document.block_type).to eq("time_period")
      end
    end
  end
end
