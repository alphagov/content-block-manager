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

  it "should render an select field populated with WorldLocations with the UK as the blank option" do
    render_inline(
      described_class.new(
        edition:,
        schema:,
        field:,
      ),
    )

    expected_name = "edition[details][country]"
    expected_id = "#{Edition::Details::Fields::BaseComponent::PARENT_CLASS}_details_country"

    expect(page).to have_css "label", text: "Country"
    expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"

    expect(page).to have_css "select option", count: all_locations.count

    expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]", text: uk.name

    world_locations.each do |location|
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"#{location.name}\"]", text: location.name
    end
  end

  it "should show an option as selected when value is given" do
    render_inline(
      described_class.new(
        edition:,
        field:,
        schema:,
        value: world_locations.first.name,
      ),
    )

    expected_name = "edition[details][country]"
    expected_id = "#{Edition::Details::Fields::BaseComponent::PARENT_CLASS}_details_country"

    expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"]"
    expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"\"]", text: uk.name

    world_locations.each do |location|
      expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"#{location.name}\"]", text: location.name
    end

    expect(page).to have_css "select[name=\"#{expected_name}\"][id=\"#{expected_id}\"] option[value=\"#{world_locations.first.name}\"][selected]", text: world_locations.first.name
  end

  it "should show errors when present" do
    edition.errors.add(:details_country, "Some error goes here")

    render_inline(
      described_class.new(
        edition:,
        field:,
        schema:,
        enum: %w[country],
      ),
    )

    expect(page).to have_css ".govuk-form-group--error"
    expect(page).to have_css ".govuk-error-message", text: "Some error goes here"
    expect(page).to have_css "select.govuk-select--error"
  end

  describe "#options" do
    it "returns a list of countries" do
      component = described_class.new(
        edition:,
        field:,
        schema:,
      )

      expected = [
        { text: "United Kingdom", value: "", selected: false },
        { text: world_locations[0].name, value: world_locations[0].name, selected: false },
        { text: world_locations[1].name, value: world_locations[1].name, selected: false },
        { text: world_locations[2].name, value: world_locations[2].name, selected: false },
        { text: world_locations[3].name, value: world_locations[3].name, selected: false },
        { text: world_locations[4].name, value: world_locations[4].name, selected: false },
      ]

      expect(component.options).to eq(expected)
    end

    it "sets an option as selected when value is provided" do
      component = described_class.new(
        edition:,
        field:,
        schema:,
        value: world_locations.first.name,
      )

      expected = [
        { text: "United Kingdom", value: "", selected: false },
        { text: world_locations[0].name, value: world_locations[0].name, selected: true },
        { text: world_locations[1].name, value: world_locations[1].name, selected: false },
        { text: world_locations[2].name, value: world_locations[2].name, selected: false },
        { text: world_locations[3].name, value: world_locations[3].name, selected: false },
        { text: world_locations[4].name, value: world_locations[4].name, selected: false },
      ]

      expect(component.options).to eq(expected)
    end
  end
end
