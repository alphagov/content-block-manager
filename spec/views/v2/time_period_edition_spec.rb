RSpec.describe "v2/time_period_editions/new", type: :view do
  describe "when rendering the new template" do
    let(:edition) { create(:v2_time_period_edition) }

    before do
      assign(:edition, edition)
      assign(:document, edition.document)

      allow(Organisation).to receive(:all).and_return([])
    end

    context "when no document is provided" do
      before do
        without_partial_double_verification do
          allow(view).to receive(:document_id_in_params?).and_return(false)
        end
      end

      it "should attach the required data attributes to enable the 'unused changes prompt' for the user" do
        render

        expect(rendered).to have_css('form[data-module~="unsaved-changes-prompt"]')
      end

      it "should attach the required data attributes to enable the 'ga4 form tracking' for the user" do
        render

        expect(rendered).to have_css('form[data-ga4-action="create"]')
        expect(rendered).to have_css('form[data-module~="ga4-form-tracker"]')
        expect(rendered).to have_css('form[data-ga4-tool-name="time_period"]')
      end

      it "should include a link to the unnested time period edition path without :document_id" do
        render

        expect(rendered).to have_css('form[action="/v2/time_period_editions"]')
      end
    end

    context "when document id is provided" do
      before do
        without_partial_double_verification do
          allow(view).to receive(:document_id_in_params?).and_return(true)
        end
      end

      it "should include a link to the unnested time period edition path with :document_id" do
        controller.params[:document_id] = 123
        render

        expect(rendered).to have_css("form[action=\"/v2/documents/#{edition.document.id}/editions\"]")
      end
    end
  end
end
