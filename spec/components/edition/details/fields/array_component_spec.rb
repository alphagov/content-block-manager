RSpec.describe Edition::Details::Fields::ArrayComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::ArrayComponent }

  let(:edition) { build(:edition, :pension) }
  let(:default_value) { nil }
  let(:schema) { double(:schema, block_type: "schema") }
  let(:nested_fields) do
    [
      build("field", name: "label", enum_values: nil, default_value: nil, label: "Label"),
      build("field", name: "telephone_number", enum_values: nil, default_value: nil, label: "Telephone number"),
    ]
  end
  let(:field) { build("field", name: "items", is_required?: true, default_value:, label: "Items", nested_fields:, format: "array") }
  let(:field_value) { nil }
  let(:object_title) { nil }

  let(:context) do
    Edition::Details::Fields::Context.new(edition:, field:, schema:, object_title:)
  end

  let(:component) do
    described_class.new(context)
  end

  before do
    allow(context).to receive(:value).and_return(field_value)
  end

  describe "when there are no items present" do
    it "renders with one empty item" do
      render_inline component

      expect(page).to have_css ".app-c-content-block-manager-array-component" do |component|
        expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", count: 1

        expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
          expect_form_fields(fieldset:, index: 0, fields: nested_fields)
        end
      end
    end

    context "when the add_another param is set" do
      before do
        vc_test_request.request_parameters = { add_another: field.name }
      end

      it "renders with an extra empty item" do
        render_inline component

        expect(page).to have_css ".app-c-content-block-manager-array-component" do |component|
          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", count: 2

          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
            expect_form_fields(fieldset:, index: 0, fields: nested_fields)
          end

          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 2/ do |fieldset|
            expect_form_fields(fieldset:, index: 1, fields: nested_fields)
          end
        end
      end
    end
  end

  describe "when there are items present" do
    let(:field_value) do
      [
        {
          "label" => "Foo",
          "telephone_number" => "01234567890",
        },
        {
          "label" => "Bar",
          "telephone_number" => "09876543210",
        },
      ]
    end

    it "renders a fieldset for each item and a template" do
      render_inline component

      expect(page).to have_css ".app-c-content-block-manager-array-component" do |component|
        expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", count: 2

        expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
          expect_form_fields(fieldset:, index: 0, fields: nested_fields, values: field_value[0])
        end

        expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 2/ do |fieldset|
          expect_form_fields(fieldset:, index: 1, fields: nested_fields, values: field_value[1])
        end
      end
    end

    it "renders the hidden delete checkbox for each item" do
      render_inline component

      expect(page).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
        expect(fieldset).to have_css "input[type='checkbox'][name='edition[details][items][][_destroy]']"
      end

      expect(page).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 2/ do |fieldset|
        expect(fieldset).to have_css "input[type='checkbox'][name='edition[details][items][][_destroy]']"
      end
    end

    context "when the add_another param is set" do
      before do
        vc_test_request.request_parameters = { add_another: field.name }
      end

      it "renders with an extra empty item" do
        render_inline component

        expect(page).to have_css ".app-c-content-block-manager-array-component" do |component|
          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", count: 3

          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
            expect_form_fields(fieldset:, index: 0, fields: nested_fields, values: field_value[0])
          end

          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 2/ do |fieldset|
            expect_form_fields(fieldset:, index: 1, fields: nested_fields, values: field_value[1])
          end

          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 3/ do |fieldset|
            expect_form_fields(fieldset:, index: 2, fields: nested_fields)
          end
        end
      end
    end
  end

  describe "when an object title is provided" do
    let(:object_title) { "field" }
    let(:field_value) do
      [
        {
          "label" => "Foo",
          "telephone_number" => "01234567890",
        },
        {
          "label" => "Bar",
          "telephone_number" => "09876543210",
        },
      ]
    end

    let(:latest_published_edition) { build(:edition, :contact, details:) }

    before do
      allow(edition.document).to receive(:latest_published_edition).and_return(latest_published_edition)
    end

    describe "when all items have previously been published" do
      let(:details) do
        {
          object_title => {
            field.name => field_value,
          },
        }
      end

      it "does not render any deletion checkboxes" do
        render_inline component

        expect(page).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
          expect(fieldset).to have_css "input[type='hidden'][name='edition[details][items][][_destroy]'][value='0']", visible: false
          expect(fieldset).to_not have_css "input[type='checkbox'][name='edition[details][items][][_destroy]']"
        end

        expect(page).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 2/ do |fieldset|
          expect(fieldset).to have_css "input[type='hidden'][name='edition[details][items][][_destroy]'][value='0']", visible: false
          expect(fieldset).to_not have_css "input[type='checkbox'][name='edition[details][items][][_destroy]']"
        end
      end
    end

    describe "one item has been previously published" do
      let(:details) do
        {
          object_title => {
            field.name => [field_value[0]],
          },
        }
      end

      it "renders a deletion checkbox for the unpublished item only" do
        render_inline component

        expect(page).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
          expect(fieldset).to have_css "input[type='hidden'][name='edition[details][items][][_destroy]'][value='0']", visible: false
          expect(fieldset).to_not have_css "input[type='checkbox'][name='edition[details][items][][_destroy]']"
        end

        expect(page).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 2/ do |fieldset|
          expect(fieldset).to have_css "input[type='checkbox'][name='edition[details][items][][_destroy]']"
          expect(fieldset).to_not have_css "input[type='hidden'][name='edition[details][items][][_destroy]'][value='0']", visible: false
        end
      end
    end
  end

private

  def expect_form_fields(fieldset:, index:, fields:, values: {})
    expect(fieldset).to have_css ".govuk-fieldset__legend", text: "Item #{index + 1}"

    fields.each do |field|
      expect(fieldset).to have_css ".govuk-label", text: field.label

      input = fieldset.find("input[name='#{field.name_attribute}']")
      expect(input).to_not be_nil
      if values[field.name]
        expect(input.value).to eq(values[field.name])
      else
        expect(input.value).to be_nil
      end
    end
  end
end
