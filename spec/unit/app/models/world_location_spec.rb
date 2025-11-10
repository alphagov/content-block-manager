RSpec.describe WorldLocation do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe "#countries" do
    let(:uk) { { "title" => "United Kingdom" } }
    let(:usa) { { "title" => "United States of America" } }
    let(:france) { { "title" => "France" } }

    let(:response) do
      {
        "results" => [uk, usa, france],
      }
    end

    it "fetches locations and orders them alphabetically" do
      allow(Services.publishing_api).to receive(:get_content_items)
              .with(document_type: "world_location",
                    fields: %w[title],
                    per_page: "500")
              .and_return(response)

      expected_countries = [
        "France",
        "United Kingdom",
        "United States of America",
      ]

      locations = WorldLocation.countries

      expect(locations.size).to eq(3)
      expect(locations.map(&:name)).to eq(expected_countries)
    end

    it "caches results" do
      allow(Services.publishing_api).to receive(:get_content_items)
              .with(document_type: "world_location",
                    fields: %w[title],
                    per_page: "500")
              .once
              .and_return(response)

      assert(5.times { WorldLocation.countries })
    end
  end
end
