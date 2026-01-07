RSpec.describe Edition::Details::Fields::ObjectComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::ObjectComponent }

  let(:edition) { build(:edition, :pension) }
  let(:nested_fields) do
    [
      build("field", name: "label", enum_values: nil, default_value: nil, label: "Label"),
      build("field", name: "type", enum_values: %w[enum_1 enum_2 enum_3], default_value: nil, label: "Type"),
      build("field", name: "email_address", enum_values: nil, default_value: nil, label: "Email address"),
    ]
  end
  let(:schema) { double("schema", id: "root", block_type: "schema") }
  let(:field) { build(:field, name: "nested", nested_fields:, schema:, is_required?: true, default_value: nil, show_field: nil, label: "Nested") }

  let(:label_stub) { double("string_component") }
  let(:type_stub) { double("enum_component") }
  let(:email_address_stub) { double("string_component") }

  let(:form_value) { nil }
  let(:populate_with_defaults) { true }

  let(:component) do
    described_class.new(
      edition:,
      field:,
      schema:,
      value: form_value,
      populate_with_defaults:,
    )
  end

  it "renders fields for each property" do
    render_inline(component)

    expect(page).to have_css(".govuk-fieldset") do |fieldset|
      expect(fieldset).to have_css ".govuk-fieldset__legend--m h3", text: "Nested"
      expect(fieldset).to have_css ".govuk-form-group", count: 3

      expect(fieldset).to have_css ".govuk-form-group", text: /Label/ do |form_group|
        expect(form_group).to have_css "input[name=\"#{nested_fields[0].name_attribute}\"]"
      end

      expect(fieldset).to have_css ".govuk-form-group", text: /Type/ do |form_group|
        expect(form_group).to have_css "input[name=\"#{nested_fields[1].name_attribute}\"]"
      end

      expect(fieldset).to have_css ".govuk-form-group", text: /Email address/ do |form_group|
        expect(form_group).to have_css "input[name=\"#{nested_fields[2].name_attribute}\"]"
      end
    end
  end

  describe "when values are present for the object" do
    let(:form_value) do
      {
        "label" => "something",
      }
    end

    it "renders the field with the value" do
      render_inline(component)

      expect(page).to have_css "input[name=\"#{nested_fields[0].name_attribute}\"][value=\"something\"]"
    end
  end

  describe "when default values are present for the object" do
    let(:nested_fields) do
      [
        build(:field, name: "label", enum_values: nil, default_value: "LABEL DEFAULT"),
        build(:field, name: "type", enum_values: %w[enum_1 enum_2 enum_3], default_value: "TYPE DEFAULT"),
        build(:field, name: "email_address", enum_values: nil, default_value: "EMAIL DEFAULT"),
      ]
    end

    it "renders the field with the default values" do
      render_inline(component)

      expect(page.find("input[name=\"#{nested_fields[0].name_attribute}\"]").value).to eq("LABEL DEFAULT")
      expect(page.find("input[name=\"#{nested_fields[1].name_attribute}\"]").value).to eq("TYPE DEFAULT")
      expect(page.find("input[name=\"#{nested_fields[2].name_attribute}\"]").value).to eq("EMAIL DEFAULT")
    end

    describe "but populate_with_defaults is false" do
      let(:populate_with_defaults) { false }

      it "leaves the fields empty" do
        render_inline(component)

        expect(page.find("input[name=\"#{nested_fields[0].name_attribute}\"]").value).to be_nil
        expect(page.find("input[name=\"#{nested_fields[1].name_attribute}\"]").value).to be_nil
        expect(page.find("input[name=\"#{nested_fields[2].name_attribute}\"]").value).to be_nil
      end
    end

    describe "but real values are also present" do
      let(:form_value) do
        {
          "label" => "Real Label",
          "type" => "Real Type",
          "email_address" => "Real Email Address",
        }
      end

      it "renders the real values instead of defaults" do
        render_inline(component)

        expect(page.find("input[name=\"#{nested_fields[0].name_attribute}\"]").value).to eq("Real Label")
        expect(page.find("input[name=\"#{nested_fields[1].name_attribute}\"]").value).to eq("Real Type")
        expect(page.find("input[name=\"#{nested_fields[2].name_attribute}\"]").value).to eq("Real Email Address")
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
        expect(form_group).to have_css "input.govuk-input--error"
      end

      expect(page).to have_css ".govuk-form-group.govuk-form-group--error", text: /Email address/ do |form_group|
        expect(form_group).to have_css ".govuk-error-message", text: "Email address error"
        expect(form_group).to have_css "input.govuk-input--error"
      end
    end
  end

  context "when a show_field is present" do
    let(:hint) { nil }
    let(:nested_fields) do
      [
        build("field", name: "show", label: "Show", hint:),
        build("field", name: "label", label: "Label"),
        build("field", name: "email_address", label: "Email address"),
      ]
    end
    let(:field) { build(:field, name: "nested", nested_fields:, schema:, is_required?: true, default_value: nil, show_field: nested_fields[0], label: "Nested") }

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
      let(:form_value) do
        {
          "show" => true,
        }
      end

      it "checks the checkbox" do
        render_inline(component)

        expect(page).to have_css "input[name=\"#{nested_fields[0].name_attribute}\"][checked='checked']"
      end
    end

    context "when the checkbox has an associated hint" do
      let(:hint) { "This is a hint" }

      it "renders the hint" do
        render_inline(component)

        expect(page).to have_css "##{nested_fields[0].id_attribute}-0-item-hint", text: hint
      end
    end
  end
end
