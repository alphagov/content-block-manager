RSpec.describe Edition::Details::Fields::StringComponent, type: :component do
  let(:edition) { build(:edition, :pension) }
  let(:field) { build("field", name: "email_address", is_required?: true, default_value: nil, label: "Email address") }
  let(:schema) { double(:schema, block_type: "schema") }

  let(:described_class) { Edition::Details::Fields::StringComponent }

  it "should render an input field with default parameters" do
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
    optional_field = build(:field, name: "email_address", is_required?: false, default_value: nil, label: "Email address")

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
    allow(field).to receive(:hint).and_return("Some hint text")

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
      allow(field).to receive(:label).and_return("Email address translated")

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

      expect(page).to have_css "input[type=\"text\"][name=\"#{field.name_attribute}\"][id=\"#{field.id_attribute}\"]"
    end

    it "should use the subschema for the hint text when provided" do
      allow(field).to receive(:hint).and_return("Some hint text")

      render_inline component

      expect(page).to have_css ".govuk-hint", text: "Some hint text"
    end
  end

  describe "when an index is present" do
    let(:component) do
      described_class.new(
        edition:,
        field:,
        schema:,
        value: "some custom value",
        index: 1,
      )
    end

    it "should call id_attribute and error_key with the index" do
      allow(field).to receive(:id_attribute).and_call_original
      allow(field).to receive(:error_key).and_call_original

      render_inline component

      expect(field).to have_received(:id_attribute).with(1).at_least(:once)
      expect(field).to have_received(:error_key).with(1).at_least(:once)
    end
  end
end
