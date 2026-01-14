RSpec.describe Edition::Details::Fields::ArrayComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::ArrayComponent }

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

  it "renders inside a Turbo Frame with the correct ID" do
    render_inline component

    expect(page).to have_css "turbo-frame[id='array-component-#{edition.id}-#{context.id}']"
  end

  describe "when there are no items present" do
    context "and the field is required" do
      before do
        allow(field).to receive(:is_required?).and_return(true)
      end

      it "renders with one empty item" do
        render_inline component

        expect(page).to have_css ".app-c-content-block-manager-array-component" do |component|
          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", count: 1

          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
            expect_form_fields(fieldset:, index: 0)
          end
        end
      end

      it "prompts the user to add another item" do
        render_inline component

        expect(page).to have_css ".govuk-button", text: I18n.t("buttons.add_another", item: field.label.singularize.downcase)
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
              expect_form_fields(fieldset:, index: 0)
            end

            expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 2/ do |fieldset|
              expect_form_fields(fieldset:, index: 1)
            end
          end
        end

        it "prompts the user to add another item" do
          render_inline component

          expect(page).to have_css ".govuk-button", text: I18n.t("buttons.add_another", item: field.label.singularize.downcase)
        end
      end
    end

    context "and the field is not required" do
      before do
        allow(field).to receive(:is_required?).and_return(false)
      end

      it "renders with no empty items" do
        render_inline component

        expect(page).to have_css ".app-c-content-block-manager-array-component" do |component|
          expect(component).to_not have_css ".app-c-content-block-manager-array-item-component__fieldset"
        end
      end

      it "prompts the user to add an item" do
        render_inline component

        expect(page).to have_css ".govuk-button", text: I18n.t("buttons.add", item: field.label.singularize.downcase)
      end

      context "when the add_another param is set" do
        before do
          vc_test_request.request_parameters = { add_another: field.name }
        end

        it "renders with one empty item" do
          render_inline component

          expect(page).to have_css ".app-c-content-block-manager-array-component" do |component|
            expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", count: 1

            expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
              expect_form_fields(fieldset:, index: 0)
            end
          end
        end

        it "prompts the user to add another item" do
          render_inline component

          expect(page).to have_css ".govuk-button", text: I18n.t("buttons.add_another", item: field.label.singularize.downcase)
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
          expect_form_fields(fieldset:, index: 0, values: field_value[0])
        end

        expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 2/ do |fieldset|
          expect_form_fields(fieldset:, index: 1, values: field_value[1])
        end
      end
    end

    it "renders the hidden delete checkbox for each item" do
      render_inline component

      expect(page).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
        expect(fieldset).to have_css "input[type='checkbox'][name='#{field.name_attribute}[_destroy]']"
      end

      expect(page).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 2/ do |fieldset|
        expect(fieldset).to have_css "input[type='checkbox'][name='#{field.name_attribute}[_destroy]']"
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

        expect(page).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
          expect(fieldset).to have_text "Label is invalid"
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
          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", count: 3

          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
            expect_form_fields(fieldset:, index: 0, values: field_value[0])
          end

          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 2/ do |fieldset|
            expect_form_fields(fieldset:, index: 1, values: field_value[1])
          end

          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 3/ do |fieldset|
            expect_form_fields(fieldset:, index: 2)
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
          expect(fieldset).to have_css "input[type='hidden'][name='#{field.name_attribute}[_destroy]'][value='0']", visible: false
          expect(fieldset).to_not have_css "input[type='checkbox'][name='#{field.name_attribute}[_destroy]']"
        end

        expect(page).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 2/ do |fieldset|
          expect(fieldset).to have_css "input[type='hidden'][name='#{field.name_attribute}[_destroy]'][value='0']", visible: false
          expect(fieldset).to_not have_css "input[type='checkbox'][name='#{field.name_attribute}[_destroy]']"
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
          expect(fieldset).to have_css "input[type='hidden'][name='#{field.name_attribute}[_destroy]'][value='0']", visible: false
          expect(fieldset).to_not have_css "input[type='checkbox'][name='#{field.name_attribute}[_destroy]']"
        end

        expect(page).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 2/ do |fieldset|
          expect(fieldset).to have_css "input[type='checkbox'][name='#{field.name_attribute}[_destroy]']"
          expect(fieldset).to_not have_css "input[type='hidden'][name='#{field.name_attribute}[_destroy]'][value='0']", visible: false
        end
      end
    end
  end

  describe "a field is deeply nested" do
    let(:parent_indexes) { [1] }
    let(:context) do
      Edition::Details::Fields::Context.new(edition:, field:, schema:, object_title:, parent_indexes:)
    end

    context "and the field is required" do
      before do
        allow(field).to receive(:is_required?).and_return(true)
      end

      it "renders with one empty item" do
        render_inline component

        expect(page).to have_css ".app-c-content-block-manager-array-component" do |component|
          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", count: 1

          expect(component).to have_css ".app-c-content-block-manager-array-item-component__fieldset", text: /Item 1/ do |fieldset|
            expect_form_fields(fieldset:, index: 0, parent_indexes:)
          end
        end
      end
    end

    context "and the field is not required" do
      before do
        allow(field).to receive(:is_required?).and_return(false)
      end

      it "renders with no items" do
        render_inline component

        expect(page).to have_css ".app-c-content-block-manager-array-component" do |component|
          expect(component).to_not have_css ".app-c-content-block-manager-array-item-component__fieldset", count: 1
        end
      end
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
