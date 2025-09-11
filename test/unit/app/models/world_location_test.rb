require "test_helper"

class WorldLocationTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    Rails.stubs(:cache).returns(memory_store)
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
      Services.publishing_api.expects(:get_content_items)
              .with(document_type: "world_location",
                    fields: %w[title],
                    per_page: "500")
              .returns(response)

      expected_countries = [
        "France",
        "United Kingdom",
        "United States of America",
      ]

      locations = WorldLocation.countries

      assert_equal 3, locations.size
      assert_equal expected_countries, locations.map(&:name)
    end

    it "caches results" do
      Services.publishing_api.expects(:get_content_items)
              .with(document_type: "world_location",
                    fields: %w[title],
                    per_page: "500")
              .once
              .returns(response)

      assert(5.times { WorldLocation.countries })
    end
  end
end
