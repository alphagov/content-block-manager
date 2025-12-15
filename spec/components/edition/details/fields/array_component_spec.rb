RSpec.describe Edition::Details::Fields::ArrayComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::ArrayComponent }

  let(:edition) { build(:edition, :pension) }
  let(:default_value) { nil }
  let(:field) { double("field", name: "items", array_items:, is_required?: true, default_value:) }
  let(:schema) { double(:schema, block_type: "schema") }
  let(:array_items) { { "type" => "string" } }
  let(:field_value) { nil }
  let(:object_title) { nil }

  let(:helper_stub) { double(:helpers) }

  let(:component) do
    described_class.new(
      edition:,
      field:,
      schema:,
      value: field_value,
      object_title:,
    )
  end

  before do
    allow(component).to receive(:helpers).and_return(helper_stub)
    allow(helper_stub).to receive(:humanized_label).and_return("Item")
    allow(helper_stub).to receive(:hint_text).and_return(nil)
  end

  describe "when there are no items present" do
    it "renders with one empty item and a template" do
      render_inline component

      expect(page).to have_css ".gem-c-add-another" do |component|
        expect(component).to have_css ".js-add-another__fieldset", count: 1
        expect(component).to have_css ".js-add-another__empty", count: 1

        expect(component).to have_css ".js-add-another__fieldset", text: /Item 1/ do |fieldset|
          expect_form_fields(fieldset, 0)
        end

        expect(component).to have_css ".js-add-another__empty", text: /Item 2/ do |fieldset|
          expect_form_fields(fieldset, 1)
        end
      end
    end
  end

  describe "when there are items present" do
    let(:field_value) { %w[foo bar] }

    it "renders a fieldset for each item and a template" do
      render_inline component

      expect(page).to have_css ".gem-c-add-another" do |component|
        expect(component).to have_css ".js-add-another__fieldset", count: 2
        expect(component).to have_css ".js-add-another__empty", count: 1

        expect(component).to have_css ".js-add-another__fieldset", text: /Item 1/ do |fieldset|
          expect_form_fields(fieldset, 0, "foo", 2)
        end

        expect(component).to have_css ".js-add-another__fieldset", text: /Item 2/ do |fieldset|
          expect_form_fields(fieldset, 1, "bar", 2)
        end

        expect(component).to have_css ".js-add-another__empty", text: /Item 3/ do |fieldset|
          expect_form_fields(fieldset, 2)
        end
      end
    end

    it "renders the hidden delete checkbox for each item" do
      render_inline component

      expect(page).to have_css ".js-add-another__fieldset", text: /Item 1/ do |fieldset|
        expect(fieldset).to have_css "input[type='checkbox'][name='edition[details][items][][_destroy]']"
      end

      expect(page).to have_css ".js-add-another__fieldset", text: /Item 2/ do |fieldset|
        expect(fieldset).to have_css "input[type='checkbox'][name='edition[details][items][][_destroy]']"
      end
    end
  end

  describe "when an object title is provided" do
    let(:field_value) { %w[foo bar] }
    let(:object_title) { "field" }

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

        expect(page).to have_css ".js-add-another__fieldset", text: /Item 1/ do |fieldset|
          expect(fieldset).to have_css "input[type='hidden'][name='edition[details][items][][_destroy]'][value='0']", visible: false
          expect(fieldset).to_not have_css "input[type='checkbox'][name='edition[details][items][][_destroy]']"
        end

        expect(page).to have_css ".js-add-another__fieldset", text: /Item 2/ do |fieldset|
          expect(fieldset).to have_css "input[type='hidden'][name='edition[details][items][][_destroy]'][value='0']", visible: false
          expect(fieldset).to_not have_css "input[type='checkbox'][name='edition[details][items][][_destroy]']"
        end
      end
    end

    describe "one item has been previously published" do
      let(:details) do
        {
          object_title => {
            field.name => %w[foo],
          },
        }
      end

      it "renders a deletion checkbox for the unpublished item only" do
        render_inline component

        expect(page).to have_css ".js-add-another__fieldset", text: /Item 1/ do |fieldset|
          expect(fieldset).to have_css "input[type='hidden'][name='edition[details][items][][_destroy]'][value='0']", visible: false
          expect(fieldset).to_not have_css "input[type='checkbox'][name='edition[details][items][][_destroy]']"
        end

        expect(page).to have_css ".js-add-another__fieldset", text: /Item 2/ do |fieldset|
          expect(fieldset).to have_css "input[type='checkbox'][name='edition[details][items][][_destroy]']"
          expect(fieldset).to_not have_css "input[type='hidden'][name='edition[details][items][][_destroy]'][value='0']", visible: false
        end
      end
    end
  end

private

  def expect_form_fields(fieldset, index, value = nil, form_group_count = 1)
    expect(fieldset).to have_css ".govuk-fieldset__legend", text: "Item #{index + 1}"
    expect(fieldset).to have_css ".govuk-form-group", count: form_group_count
    expect(fieldset).to have_css "input[value='#{value}']" unless value.nil?
    expect(fieldset).to have_css ".govuk-label", text: "Item"
  end
end
