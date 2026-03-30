RSpec.describe Edition::Details::Fields::SortableArrayComponent, type: :component do
  let(:edition) { build(:edition, :pension) }
  let(:schema) { build(:schema) }
  let(:field) { Schema::Field.new("items", schema) }
  let(:nested_fields) { field.nested_fields }

  let(:body) do
    {
      "properties" => {
        "items" => {
          "type" => "array",
          "items" => {
            "type" => "object",
            "properties" => {
              "label" => { "type" => "string" },
              "telephone_number" => { "type" => "string" },
            },
          },
        },
      },
    }
  end

  let(:object_title) { nil }
  let(:field_value) { nil }
  let(:context) do
    Edition::Details::Fields::Context.new(edition:, field:, schema:, object_title:)
  end

  let(:component) do
    described_class.new(context)
  end

  before do
    allow(context).to receive(:value).and_return(field_value)
    allow(schema).to receive(:body).and_return(body)
  end

  describe "when there are no items present" do
    context "and the field is required" do
      before do
        allow(field).to receive(:is_required?).and_return(true)
      end

      it "renders two fieldsets, one visible and one to be hidden by JS" do
        render_inline component

        expect(page).to have_css ".app-c-content-block-manager-array-component--sortable" do |component|
          expect(component).to have_css ".govuk-fieldset", count: 2
          expect(component).to have_css ".govuk-fieldset", text: /Item 1/ do |fieldset|
            expect_form_fields(fieldset:, index: 0)
          end
          expect(component).to have_css ".govuk-fieldset", text: /Item 2/ do |fieldset|
            expect_form_fields(fieldset:, index: 1)
          end
        end
      end

      it "does not render a deletion checkbox" do
        render_inline component

        expect(page).to_not have_css "input[type='checkbox'][name='#{field.name_attribute}[_destroy]']"
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
        expect(component).to have_css ".govuk-fieldset", count: 3

        expect(component).to have_css ".govuk-fieldset", text: /Item 1/ do |fieldset|
          expect_form_fields(fieldset:, index: 0, values: field_value[0])
        end

        expect(component).to have_css ".govuk-fieldset", text: /Item 2/ do |fieldset|
          expect_form_fields(fieldset:, index: 1, values: field_value[1])
        end

        expect(component).to have_css ".govuk-fieldset", text: /Item 3/ do |fieldset|
          expect(fieldset).to have_css "input[id='edition_details_items_2_label']" do |input|
            expect(input.value).to be_nil
          end
        end
      end
    end

    describe "when there are errors present" do
      before do
        edition.errors.add(nested_fields[0].error_key([0]).to_sym, "Label is invalid")
        edition.errors.add(nested_fields[1].error_key([0]).to_sym, "Telephone number is invalid")

        edition.errors.add(nested_fields[0].error_key([1]).to_sym, "Label is invalid")
        edition.errors.add(nested_fields[1].error_key([1]).to_sym, "Telephone number is invalid")
      end

      it "should render the error messages" do
        render_inline component

        expect(page).to have_css ".govuk-fieldset", text: /Item 1/ do |fieldset|
          expect(fieldset).to have_text "Label is invalid"
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
  end

private

  def expect_form_fields(fieldset:, index:, values: {}, parent_indexes: [])
    expect(fieldset).to have_css ".govuk-fieldset__legend", text: "Item #{index + 1}"

    nested_fields.each do |field|
      expect(fieldset).to have_css ".govuk-label", text: field.label

      input = fieldset.find("input[name='#{field.name_attribute}'][id='#{field.id_attribute([*parent_indexes, index])}']")
      expect(input).to_not be_nil
      if values[field.name]
        expect(input.value).to eq(values[field.name])
      else
        expect(input.value).to be_nil
      end
    end
  end
end
