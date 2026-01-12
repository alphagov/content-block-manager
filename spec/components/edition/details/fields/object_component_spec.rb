RSpec.describe Edition::Details::Fields::ObjectComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::ArrayComponent }

  let(:edition) { build(:edition, :pension) }
  let(:schema) { build(:schema) }
  let(:field) { Schema::Field.new("nested", schema) }
  let(:nested_fields) { field.nested_fields }

  let(:body) do
    {
      "properties" => {
        "nested" => {
          "type" => "object",
          "properties" => {
            "label" => { "type" => "string" },
            "type" => { "type" => "string", "enum" => %w[enum_1 enum_2 enum_3] },
            "email_address" => { "type" => "string" },
          },
        },
      },
    }
  end

  let(:context) do
    Edition::Details::Fields::Context.new(edition:, field:, schema:)
  end

  let(:described_class) { Edition::Details::Fields::ObjectComponent }
  let(:component) { described_class.new(context) }

  before do
    allow(schema).to receive(:body).and_return(body)
  end

  it "renders fields for each property" do
    render_inline(component)

    expect(page).to have_css(".govuk-fieldset") do |fieldset|
      expect(fieldset).to have_css ".govuk-fieldset__legend--m h3", text: "Nested"
      expect(fieldset).to have_css ".govuk-form-group", count: 3

      expect_form_fields(fieldset: fieldset)
    end
  end

  describe "when values are present for the object" do
    let(:nested_value) { "value" }
    let(:values) { { nested_fields[0].name => nested_value } }

    before do
      allow(context).to receive(:value).and_return(values)
    end

    it "renders the field with the value" do
      render_inline(component)

      expect(page).to have_css(".govuk-fieldset") do |fieldset|
        expect_form_fields(fieldset: fieldset, values: values)
      end
    end
  end

  describe "when errors are present for the object" do
    before do
      edition.errors.add(nested_fields[0].error_key, "Label error")
      edition.errors.add(nested_fields[1].error_key, "Type error")
      edition.errors.add(nested_fields[2].error_key, "Email address error")
    end

    it "should show errors" do
      render_inline(component)

      expect(page).to have_css ".govuk-form-group.govuk-form-group--error", text: /Label/ do |form_group|
        expect(form_group).to have_css ".govuk-error-message", text: "Label error"
        expect(form_group).to have_css "input.govuk-input--error"
      end

      expect(page).to have_css ".govuk-form-group.govuk-form-group--error", text: /Type/ do |form_group|
        expect(form_group).to have_css ".govuk-error-message", text: "Type error"
        expect(form_group).to have_css "select.govuk-select--error"
      end

      expect(page).to have_css ".govuk-form-group.govuk-form-group--error", text: /Email address/ do |form_group|
        expect(form_group).to have_css ".govuk-error-message", text: "Email address error"
        expect(form_group).to have_css "input.govuk-input--error"
      end
    end
  end

  context "when a show_field is present" do
    let(:body) do
      {
        "properties" => {
          "nested" => {
            "type" => "object",
            "properties" => {
              "show" => { "type" => "boolean" },
              "label" => { "type" => "string" },
              "email_address" => { "type" => "string" },
            },
          },
        },
      }
    end
    let(:show_field) { nested_fields[0] }

    before do
      allow(field).to receive(:show_field).and_return(show_field)
    end

    it "shows a checkbox to toggle 'show' option" do
      render_inline(component)

      expect(page).to have_css "input[name=\"#{nested_fields[0].name_attribute}\"]"
      expect(page).to_not have_css "input[name=\"#{nested_fields[0].name_attribute}\"][checked='checked']"
    end

    it "nests the other fields within the checkbox component" do
      render_inline(component)

      expect(page).to have_css "div[id=\"#{nested_fields[0].id_attribute}\"]" do |wrapper|
        expect(wrapper).to have_css ".govuk-checkboxes__conditional" do
          expect(wrapper).to have_css ".govuk-form-group", count: 2

          expect(wrapper).to have_css ".govuk-form-group", text: /Label/ do |form_group|
            expect(form_group).to have_css "input[name=\"#{nested_fields[1].name_attribute}\"]"
          end

          expect(wrapper).to have_css ".govuk-form-group", text: /Email address/ do |form_group|
            expect(form_group).to have_css "input[name=\"#{nested_fields[2].name_attribute}\"]"
          end
        end
      end
    end

    context "when the checkbox is checked" do
      let(:value) { { show_field.name => true } }

      before do
        allow(context).to receive(:value).and_return(value)
      end

      it "checks the checkbox" do
        render_inline(component)

        expect(page).to have_css "input[name=\"#{show_field.name_attribute}\"][checked='checked']"
      end
    end

    context "when the checkbox has an associated hint" do
      let(:hint) { "This is a hint" }

      before do
        allow(show_field).to receive(:hint).and_return(hint)
      end

      it "renders the hint" do
        render_inline(component)

        expect(page).to have_css "##{nested_fields[0].id_attribute}-0-item-hint", text: hint
      end
    end
  end

  context "when the field is nested within an array" do
    before do
      allow(context).to receive(:indexes).and_return([1])
    end

    it "renders fields for each property" do
      render_inline(component)

      expect(page).to have_css(".govuk-fieldset") do |fieldset|
        expect(fieldset).to have_css ".govuk-fieldset__legend--m h3", text: "Nested"
        expect(fieldset).to have_css ".govuk-form-group", count: 3

        expect_form_fields(fieldset: fieldset, indexes: [1])
      end
    end
  end

private

  def expect_form_fields(fieldset:, values: {}, indexes: [])
    nested_fields.each do |field|
      expect(fieldset).to have_css ".govuk-form-group", text: field.label do |form_group|
        input = form_group.find("[name='#{field.name_attribute}'][id='#{field.id_attribute(indexes)}']")
        expect(input).to_not be_nil
        if values[field.name]
          expect(input.value).to eq(values[field.name])
        else
          expect(input.value).to be_blank
        end
      end
    end
  end
end
