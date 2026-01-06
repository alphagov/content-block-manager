RSpec.describe Edition::Details::Fields::EnumComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::EnumComponent }

  let(:edition) { build(:edition, :pension) }
  let(:enum_values) { ["a week", "a month"] }
  let(:default_value) { nil }
  let(:field) { build("field", name: "something", is_required?: true, default_value:, enum_values:, label: "Something") }
  let(:schema) { double(:schema, block_type: "schema") }
  let(:value) { nil }

  let(:context) do
    Edition::Details::Fields::Context.new(edition:, field:, schema:)
  end

  let(:component) do
    described_class.new(context)
  end

  it_behaves_like "a field component", field_type: "select", value: "a month"

  it "should render a select field with given parameters" do
    render_inline component

    expected_name = "edition[details][something]"
    expected_id = "edition_details_something"

    expect(page).to have_css "label", text: "Something"
    expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
    expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]"
    expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a week\"]", text: "a week"
    expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"a month\"]", text: "a month"
  end
end
