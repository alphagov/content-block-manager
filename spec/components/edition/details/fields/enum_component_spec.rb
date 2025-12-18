RSpec.describe Edition::Details::Fields::EnumComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::EnumComponent }
  let(:helper_stub) { double(:helpers) }

  let(:edition) { build(:edition, :pension) }
  let(:field) { build("field", name: "something", is_required?: true, default_value: nil) }
  let(:schema) { double(:schema, block_type: "schema") }

  before do
    allow_any_instance_of(described_class).to receive(:helpers).and_return(helper_stub)
    allow(helper_stub).to receive(:humanized_label).and_return("Something")
    allow(helper_stub).to receive(:hint_text).and_return(nil)
  end

  describe "when there is no default value" do
    it "should render a select field with given parameters" do
      render_inline(
        described_class.new(
          edition:,
          field:,
          schema:,
          enum: ["a week", "a month"],
        ),
      )

      expected_name = "edition[details][something]"
      expected_id = "#{Edition::Details::Fields::BaseComponent::PARENT_CLASS}_details_something"

      expect(page).to have_css "label", text: "Something"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a week\"]", text: "a week"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a month\"]", text: "a month"
    end

    it "should show an option as selected when value is given" do
      render_inline(
        described_class.new(
          edition:,
          field:,
          schema:,
          enum: ["a week", "a month"],
          value: "a week",
        ),
      )

      expected_name = "edition[details][something]"
      expected_id = "#{Edition::Details::Fields::BaseComponent::PARENT_CLASS}_details_something"

      expect(page).to have_css "label", text: "Something"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a week\"][selected]", text: "a week"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a month\"]", text: "a month"
    end
  end

  describe "when there is a default value" do
    it "should render a select field with given parameters" do
      render_inline(
        described_class.new(
          edition:,
          field:,
          schema:,
          enum: ["a week", "a month"],
          default: "a month",
        ),
      )

      expected_name = "edition[details][something]"
      expected_id = "#{Edition::Details::Fields::BaseComponent::PARENT_CLASS}_details_something"

      expect(page).to have_css "label", text: "Something"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a week\"]", text: "a week"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a month\"][selected]", text: "a month"
    end

    it "should show an option as selected when value is given" do
      render_inline(
        described_class.new(
          edition:,
          field:,
          schema:,
          enum: ["a week", "a month"],
          value: "a week",
          default: "a month",
        ),
      )

      expected_name = "edition[details][something]"
      expected_id = "#{Edition::Details::Fields::BaseComponent::PARENT_CLASS}_details_something"

      expect(page).to have_css "label", text: "Something"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a week\"][selected]", text: "a week"
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a month\"]", text: "a month"
    end
  end

  it "should show errors when present" do
    edition.errors.add(:details_something, "Some error goes here")

    render_inline(
      described_class.new(
        edition:,
        field:,
        schema:,
        enum: ["a week", "a month"],
      ),
    )

    expect(page).to have_css ".govuk-form-group--error"
    expect(page).to have_css ".govuk-error-message", text: "Some error goes here"
    expect(page).to have_css "select.govuk-select--error"
  end

  describe "#options" do
    it "returns a list of options" do
      component = described_class.new(
        edition:,
        field:,
        schema:,
        enum: ["a week", "a month"],
      )

      assert_equal component.options, [
        { text: "", value: "", selected: true },
        { text: "a week", value: "a week", selected: false },
        { text: "a month", value: "a month", selected: false },
      ]
    end

    it "sets an option as selected when value is provided" do
      component = described_class.new(
        edition:,
        field:,
        schema:,
        enum: ["a week", "a month"],
        value: "a week",
      )

      assert_equal component.options, [
        { text: "", value: "", selected: false },
        { text: "a week", value: "a week", selected: true },
        { text: "a month", value: "a month", selected: false },
      ]
    end
  end
end
