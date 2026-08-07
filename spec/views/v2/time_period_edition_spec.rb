RSpec.describe "v2/time_period_editions/new", type: :view do
  describe "when rendering the new template" do
    before do
      assign(:edition, create(:v2_time_period_edition))

      allow(Organisation).to receive(:all).and_return([])
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
  end
end
