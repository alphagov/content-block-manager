require "test_helper"

class Edition::New::SelectSchemaComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:heading) { "Some heading" }
  let(:heading_caption) { "Caption" }
  let(:error_message) { nil }
  let(:schemas) { build_list(:schema, 3) }

  let(:component) do
    Edition::New::SelectSchemaComponent.new(
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
    assert_selector "form[data-module='ga4-form-tracker'][data-ga4-form='#{form_attributes.to_json}']"

    assert_selector "button", text: "Save and continue"
    assert_selector "a", text: "Cancel"
  end

  it "renders a select component with all the schemas" do
    render_inline(component)

    assert_selector ".govuk-fieldset__heading", text: heading
    assert_selector ".govuk-caption-xl", text: heading_caption
    assert_no_selector ".govuk-error-message"

    schemas.each do |s|
      assert_selector ".govuk-radios" do
        assert_selector "input[type='radio'][name='block_type'][value='#{s.parameter}']"
        assert_selector ".govuk-radios__label", text: s.name
      end
    end
  end

  describe "when an error message is present" do
    let(:error_message) { "Some error" }

    it "shows the error message" do
      render_inline(component)

      assert_selector ".govuk-error-message", text: error_message
    end
  end
end
