RSpec.describe Edition::Details::Fields::CountryComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::CountryComponent }

  let(:edition) { build(:edition, :pension) }
  let(:field) { build("field", name: "country", is_required?: true, default_value: nil, label: "Country") }

  let(:world_locations) { 5.times.map { |i| build(:world_location, name: "World location #{i}") } }
  let(:uk) { build(:world_location, name: "United Kingdom") }

  let(:all_locations) { [world_locations, uk].flatten }

  let(:schema) { double(:schema, block_type: "schema") }

  before do
    allow(WorldLocation).to receive(:countries).and_return(all_locations)
  end

  let(:context) do
    Edition::Details::Fields::Context.new(edition:, field:, schema:)
  end

  let(:component) do
    described_class.new(context)
  end

  it_behaves_like "a field component", field_type: "select", value: "World location 2"

  it "should render an select field populated with WorldLocations with the UK as the blank option" do
    render_inline component

    expected_name = "edition[details][country]"
    expected_id = "edition_details_country"

    expect(page).to have_css "label", text: "Country"
    expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"

    expect(page).to have_css "select option", count: all_locations.count

    expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]", text: uk.name

    world_locations.each do |location|
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"#{location.name}\"]", text: location.name
    end
  end
end
