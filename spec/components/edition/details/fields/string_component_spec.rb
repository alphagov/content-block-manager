RSpec.describe Edition::Details::Fields::StringComponent, type: :component do
  let(:edition) { build(:edition, :pension) }
  let(:field) { build("field", name: "email_address", is_required?: true, default_value: nil) }
  let(:schema) { double(:schema, block_type: "schema") }

  let(:described_class) { Edition::Details::Fields::StringComponent }
  let(:helper_stub) { double(:helpers) }

  before do
    allow_any_instance_of(described_class).to receive(:helpers).and_return(helper_stub)
    allow(helper_stub).to receive(:humanized_label).and_return("Label")
    allow(helper_stub).to receive(:hint_text).and_return(nil)
  end

  it "should render an input field with default parameters" do
    allow(helper_stub).to receive(:humanized_label).and_return("Email address")

    render_inline(
      described_class.new(
        edition:,
        field:,
        schema:,
      ),
    )

    expected_name = "edition[details][email_address]"
    expected_id = "#{Edition::Details::Fields::BaseComponent::PARENT_CLASS}_details_email_address"

    expect(page).to have_css "label", text: "Email address"
    expect(page).to have_css "input[type=\"text\"][name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
  end

  it "should show optional label when field is optional" do
    optional_field = build(:field, name: "email_address", is_required?: false, default_value: nil)
    allow(helper_stub).to receive(:humanized_label).and_return("Email address")

    render_inline(
      described_class.new(
        edition:,
        field: optional_field,
        schema:,
      ),
    )

    expect(page).to have_css "label", text: "Email address (optional)"
  end

  it "should show the value when provided" do
    render_inline(
      described_class.new(
        edition:,
        field:,
        schema:,
        value: "example@example.com",
      ),
    )

    expect(page).to have_css 'input[value="example@example.com"]'
  end

  it "should show errors when present" do
    edition.errors.add(:details_email_address, "Some error goes here")

    render_inline(
      described_class.new(
        edition:,
        field:,
        schema:,
      ),
    )

    expect(page).to have_css ".govuk-form-group--error"
    expect(page).to have_css ".govuk-error-message", text: "Some error goes here"
    expect(page).to have_css "input.govuk-input--error"
  end

  it "should allow a custom value" do
    render_inline(
      described_class.new(
        edition:,
        field:,
        schema:,
        value: "some custom value",
      ),
    )

    expect(page).to have_css 'input[value="some custom value"]'
  end

  it "should render hint text when a translation exists" do
    allow(helper_stub).to receive(:hint_text).with(schema:, subschema: nil, field:).and_return("Some hint text")

    render_inline(
      described_class.new(
        edition:,
        field:,
        schema:,
        value: "some custom value",
      ),
    )

    expect(page).to have_css ".govuk-hint", text: "Some hint text"
  end

  describe "when there is a translation for a field label" do
    it "should return the translation" do
      allow(helper_stub).to receive(:humanized_label).and_return("Email address translated")

      render_inline(
        described_class.new(
          edition:,
          field:,
          schema:,
        ),
      )

      expect(page).to have_css "label", text: "Email address translated"
    end
  end

  describe "when a subschema is present" do
    let(:subschema) { double(:schema, block_type: "my_suffix") }

    let(:component) do
      described_class.new(
        edition:,
        field:,
        schema:,
        value: "some custom value",
        subschema:,
      )
    end

    it "should generate the correct name and ID" do
      render_inline component

      expected_name = "edition[details][my_suffix][email_address]"
      expected_id = "#{Edition::Details::Fields::BaseComponent::PARENT_CLASS}_details_my_suffix_email_address"

      expect(page).to have_css "input[type=\"text\"][name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
    end

    it "should use the subschema for the hint text when provided" do
      allow(helper_stub).to receive(:hint_text).with(schema:, subschema:, field:).and_return("Some hint text")

      render_inline component

      expect(page).to have_css ".govuk-hint", text: "Some hint text"
    end
  end
end
