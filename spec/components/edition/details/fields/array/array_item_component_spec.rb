RSpec.describe Edition::Details::Fields::Array::ItemComponent, type: :component do
  let(:field_name) { "foo" }
  let(:field) { build(:field, name: field_name, enum_values: nil, default_value: nil, nested_fields:) }
  let(:edition) { build(:edition) }
  let(:schema) { build(:schema) }
  let(:can_be_deleted) { true }
  let(:hints) { nil }

  let(:component) do
    described_class.new(
      field:,
      edition:,
      schema:,
      value:,
      can_be_deleted:,
      hints:,
      index:,
    )
  end

  describe "if the field contains no nested fields" do
    let(:nested_fields) { nil }
    let(:index) { 1 }
    let(:value) { "Some text" }

    describe "if the item can be deleted" do
      let(:can_be_deleted) { true }

      it "renders without the '--immutable' class, to show the 'delete' button" do
        render_inline(component)

        expect(page).to have_css ".app-c-content-block-manager-array-item-component"
        expect(page).to_not have_css ".app-c-content-block-manager-array-item-component--immutable"
      end

      it "renders a text field" do
        render_inline(component)

        expect(page).to have_css "label", text: "Foo"
        expect(page).to have_css "input[type='text'][value='Some text'][name='#{field.name_attribute}'][id='#{field.id_attribute(1)}']"
      end

      describe "when error messages are present" do
        before do
          edition.errors.add(field.error_key(1).to_sym, "Cannot be blank")
        end

        it "renders an error" do
          render_inline(component)

          expect(page).to have_css ".govuk-form-group--error" do |form_group|
            expect(form_group).to have_css ".govuk-error-message", text: "Cannot be blank"
          end
        end
      end
    end

    describe "if the item cannot be deleted" do
      let(:can_be_deleted) { false }

      it "renders with the '--immutable' class, to suppress the 'delete' button" do
        render_inline(component)

        expect(page).to have_css ".app-c-content-block-manager-array-item-component"
        expect(page).to have_css ".app-c-content-block-manager-array-item-component--immutable"
      end
    end
  end

  describe "if the field contains nested fields" do
    let(:field_1) { build(:field, name: "fizz") }
    let(:field_2) { build(:field, name: "buzz") }

    let(:nested_fields) do
      [
        field_1,
        field_2,
      ]
    end
    let(:index) { 1 }
    let(:value) do
      {
        "fizz" => "Field 1 value",
        "buzz" => "Field 2 value",
      }
    end

    it "renders a field for each item" do
      render_inline(component)

      expect(page).to have_css ".govuk-form-group", text: /Fizz/ do |form_group|
        expect(form_group).to have_css "label", text: "Fizz"
        expect(form_group).to have_css "input[type='text'][value='Field 1 value'][name='#{field_1.name_attribute}'][id='#{field_1.id_attribute(1)}']"
      end

      expect(page).to have_css ".govuk-form-group", text: /Buzz/ do |form_group|
        expect(form_group).to have_css "label", text: "Buzz"
        expect(form_group).to have_css "input[type='text'][value='Field 2 value'][name='#{field_2.name_attribute}'][id='#{field_2.id_attribute(1)}']"
      end
    end

    describe "when error messages are present" do
      before do
        edition.errors.add(field_1.error_key(1).to_sym, "Fizz cannot be blank")
        edition.errors.add(field_2.error_key(1).to_sym, "Buzz cannot be blank")
      end

      it "renders errors" do
        render_inline(component)

        expect(page).to have_css ".govuk-form-group--error", text: /Fizz/ do |form_group|
          expect(form_group).to have_css ".govuk-error-message", text: "Fizz cannot be blank"
        end

        expect(page).to have_css ".govuk-form-group--error", text: /Buzz/ do |form_group|
          expect(form_group).to have_css ".govuk-error-message", text: "Buzz cannot be blank"
        end
      end
    end
  end
end
