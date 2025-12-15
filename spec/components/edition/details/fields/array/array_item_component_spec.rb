RSpec.describe Edition::Details::Fields::Array::ItemComponent, type: :component do
  let(:component) do
    described_class.new(
      field_name:,
      array_items:,
      name_prefix:,
      id_prefix:,
      value: field_value,
      index:,
      errors:,
      error_lookup_prefix:,
      can_be_deleted:,
      hints:,
    )
  end

  let(:errors) { double(:errors) }
  let(:error_lookup_prefix) { "foo_bar" }
  let(:errors_for_field) { [] }
  let(:can_be_deleted) { true }
  let(:hints) { nil }

  before do
    allow(component).to receive(:errors_for).and_return(errors_for_field)
  end

  describe "if the array item is a string" do
    let(:field_name) { "bar" }
    let(:array_items) { { "type" => "string" } }
    let(:name_prefix) { "foo[bar]" }
    let(:id_prefix) { "foo_bar" }
    let(:field_value) { ["", "Some text"] }
    let(:index) { 1 }

    describe "if the item can be deleted" do
      let(:can_be_deleted) { true }

      it "renders without the '--immutable' class, to show the 'delete' button" do
        render_inline(component)

        expect(page).to have_css ".app-c-content-block-manager-array-item-component"
        expect(page).to_not have_css ".app-c-content-block-manager-array-item-component--immutable"
      end

      it "renders a text field" do
        render_inline(component)

        expect(page).to have_css "label", text: "Bar"
        expect(page).to have_css "input[type='text'][value='Some text'][name='foo[bar][]'][id='foo_bar_1']"
      end

      describe "when error messages are present" do
        let(:errors_for_field) do
          [{ text: "Bar cannot be blank" }]
        end

        before do
          expect(component).to receive(:errors_for).with(errors, "#{error_lookup_prefix}_#{index}".to_sym).and_return(errors_for_field)
        end

        it "renders an error" do
          render_inline(component)

          expect(page).to have_css ".govuk-form-group--error" do |form_group|
            expect(form_group).to have_css ".govuk-error-message", text: "Bar cannot be blank"
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

    describe "if a hint is present" do
      let(:hints) do
        { bar: "Some hint" }
      end

      it "renders a hint" do
        render_inline(component)

        expect(page).to have_css ".govuk-form-group" do |form_group|
          expect(form_group).to have_css ".govuk-hint", text: "Some hint"
        end
      end
    end
  end

  describe "if the array item is an enum" do
    let(:field_name) { "bar" }
    let(:array_items) { { "type" => "string", "enum" => %w[foo bar baz] } }
    let(:name_prefix) { "foo[bar]" }
    let(:id_prefix) { "foo_bar" }
    let(:field_value) { nil }
    let(:index) { 1 }

    it "renders a select field" do
      render_inline(component)

      expect(page).to have_css "label", text: "Bar"
      expect(page).to have_css "select[name='foo[bar][]'][id='foo_bar_1']" do |select|
        expect(select).to have_css "option[value=''][selected]", text: "Select"
        expect(select).to have_css "option[value='foo']", text: "Foo"
        expect(select).to have_css "option[value='bar']", text: "Bar"
        expect(select).to have_css "option[value='baz']", text: "Baz"
      end
    end

    describe "when the value is set" do
      let(:field_value) { "baz" }

      it "marks the appropriate option as selected" do
        render_inline(component)

        expect(page).to have_css "label", text: "Bar"
        expect(page).to have_css "select[name='foo[bar][]'][id='foo_bar_1']" do |select|
          expect(select).to have_css "option[value='foo']", text: "Foo"
          expect(select).to have_css "option[value='bar']", text: "Bar"
          expect(select).to have_css "option[value='baz'][selected]", text: "Baz"
        end
      end
    end

    describe "when error messages are present" do
      let(:errors_for_field) do
        [{ text: "Bar cannot be blank" }]
      end

      before do
        expect(component).to receive(:errors_for).with(errors, "#{error_lookup_prefix}_#{index}".to_sym).and_return(errors_for_field)
      end

      it "renders an error" do
        render_inline(component)

        expect(page).to have_css ".govuk-form-group--error" do |form_group|
          expect(form_group).to have_css ".govuk-error-message", text: "Bar cannot be blank"
        end
      end
    end

    describe "if a hint is present" do
      let(:hints) do
        { bar: "Some hint" }
      end

      it "renders a hint" do
        render_inline(component)

        expect(page).to have_css ".govuk-form-group" do |form_group|
          expect(form_group).to have_css ".govuk-hint", text: "Some hint"
        end
      end
    end
  end

  describe "if the array item is an object" do
    let(:field_name) { "bar" }
    let(:array_items) do
      {
        "type" => "object",
        "properties" => {
          "fizz" => { "type" => "string" },
          "buzz" => { "type" => "string" },
        },
      }
    end
    let(:name_prefix) { "foo[bar]" }
    let(:id_prefix) { "foo_bar" }
    let(:field_value) { [{}, { "fizz" => "Something", "buzz" => "Else" }] }
    let(:index) { 1 }

    it "renders a text field for each item" do
      render_inline(component)

      expect(page).to have_css ".govuk-form-group", text: /Fizz/ do |form_group|
        expect(form_group).to have_css "label", text: "Fizz"
        expect(form_group).to have_css "input[type='text'][value='Something'][name='foo[bar][][fizz]'][id='foo_bar_1_fizz']"
      end

      expect(page).to have_css ".govuk-form-group", text: /Buzz/ do |form_group|
        expect(form_group).to have_css "label", text: "Buzz"
        expect(form_group).to have_css "input[type='text'][value='Else'][name='foo[bar][][buzz]'][id='foo_bar_1_buzz']"
      end
    end

    describe "when error messages are present" do
      let(:fizz_errors) do
        [{ text: "Fizz cannot be blank" }]
      end

      let(:buzz_errors) do
        [{ text: "Buzz cannot be blank" }]
      end

      before do
        expect(component).to receive(:errors_for).with(errors, "#{error_lookup_prefix}_#{index}_fizz".to_sym).and_return(fizz_errors)
        expect(component).to receive(:errors_for).with(errors, "#{error_lookup_prefix}_#{index}_buzz".to_sym).and_return(buzz_errors)
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

    describe "if a hint is present" do
      let(:hints) do
        { fizz: "Some hint", buzz: "Another hint" }
      end

      it "renders a hint" do
        render_inline(component)

        expect(page).to have_css ".govuk-form-group", text: /Fizz/ do |form_group|
          expect(form_group).to have_css ".govuk-hint", text: "Some hint"
        end

        expect(page).to have_css ".govuk-form-group", text: /Buzz/ do |form_group|
          expect(form_group).to have_css ".govuk-hint", text: "Another hint"
        end
      end
    end

    describe "when an enum is included" do
      let(:array_items) do
        {
          "type" => "object",
          "properties" => {
            "fizz" => { "type" => "string", "enum" => %w[foo bar baz] },
          },
        }
      end

      it "renders a select field" do
        render_inline(component)

        expect(page).to have_css "label", text: "Fizz"
        expect(page).to have_css "select[name='foo[bar][][fizz]'][id='foo_bar_1_fizz']" do |select|
          expect(select).to have_css "option[value='foo']", text: "Foo"
          expect(select).to have_css "option[value='bar']", text: "Bar"
          expect(select).to have_css "option[value='baz']", text: "Baz"
        end
      end

      describe "when the value is set" do
        let(:field_value) { [{}, { "fizz" => "baz" }] }

        it "marks the appropriate option as selected" do
          render_inline(component)

          expect(page).to have_css "label", text: "Fizz"
          expect(page).to have_css "select[name='foo[bar][][fizz]'][id='foo_bar_1_fizz']" do |select|
            expect(select).to have_css "option[value='foo']", text: "Foo"
            expect(select).to have_css "option[value='bar']", text: "Bar"
            expect(select).to have_css "option[value='baz'][selected]", text: "Baz"
          end
        end
      end

      describe "when error messages are present" do
        let(:errors_for_field) do
          [{ text: "Fizz cannot be blank" }]
        end

        before do
          expect(component).to receive(:errors_for).with(errors, "#{error_lookup_prefix}_#{index}_fizz".to_sym).and_return(errors_for_field)
        end

        it "renders an error" do
          render_inline(component)

          expect(page).to have_css ".govuk-form-group--error" do |form_group|
            expect(form_group).to have_css ".govuk-error-message", text: "Fizz cannot be blank"
          end
        end
      end
    end
  end
end
