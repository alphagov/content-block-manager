RSpec.describe Edition::New::ErrorSummaryComponent, type: :component do
  let(:component) do
    described_class.new(error_message:)
  end

  describe "when a message is present" do
    let(:error_message) { "Error message" }

    it "renders an error summary" do
      render_inline(component)

      expect(page).to have_css ".govuk-error-summary"
      expect(page).to have_css ".gem-c-error-summary__list-item", text: error_message
    end
  end

  describe "when a message is not present" do
    let(:error_message) { nil }

    it "does not render a summary" do
      render_inline(component)

      expect(page).not_to have_css ".govuk-error-summary"
    end
  end
end
