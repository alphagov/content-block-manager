RSpec.describe Edition::New::SelectSchemaComponent, type: :component do
  let(:heading) { "Some heading" }
  let(:heading_caption) { "Caption" }
  let(:error_message) { nil }
  let(:schemas) { build_list(:schema, 3) }

  let(:component) do
    described_class.new(
      heading:,
      heading_caption:,
      error_message:,
      schemas:,
    )
  end

  it "renders a form and buttons" do
    render_inline(component)

    form_attributes = {
      type: "Content Block",
      tool_name: nil,
      event_name: "create",
      section: "select_schema",
    }
    expect(page).to have_css "form[data-module='ga4-form-tracker'][data-ga4-form='#{form_attributes.to_json}']"

    expect(page).to have_css "button", text: "Save and continue"
    expect(page).to have_css "a", text: "Cancel"
  end

  it "renders a select component with all the schemas" do
    render_inline(component)

    expect(page).to have_css ".govuk-fieldset__heading", text: heading
    expect(page).to have_css ".govuk-caption-xl", text: heading_caption
    expect(page).not_to have_css ".govuk-error-message"

    schemas.each do |s|
      expect(page).to have_css ".govuk-radios" do
        expect(page).to have_css "input[type='radio'][name='block_type'][value='#{s.parameter}']"
        expect(page).to have_css ".govuk-radios__label", text: s.name
      end
    end
  end

  describe "when an error message is present" do
    let(:error_message) { "Some error" }

    it "shows the error message" do
      render_inline(component)

      expect(page).to have_css ".govuk-error-message", text: error_message
    end
  end
end
