require "test_helper"

class ContentBlockManager::OrganisationTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    Rails.stubs(:cache).returns(memory_store)
    Rails.cache.clear
  end

  describe "#all" do
    let(:organisation_1) do
      { "content_id" => SecureRandom.uuid, "title" => "Organisation 1" }
    end

    let(:organisation_2) do
      { "content_id" => SecureRandom.uuid, "title" => "Organisation 2" }
    end

    let(:results) do
      {
        "results" => [organisation_1, organisation_2],
      }
    end

    it "fetches organisations" do
      Services.publishing_api.expects(:get_content_items)
              .with(document_type: "organisation", per_page: "500")
              .returns(results)

      organisations = Organisation.all

      assert_equal 2, organisations.size

      assert_equal organisations.first.id, organisation_1["content_id"]
      assert_equal organisations.first.name, organisation_1["title"]

      assert_equal organisations.second.id, organisation_2["content_id"]
      assert_equal organisations.second.name, organisation_2["title"]
    end

    it "caches results" do
      Services.publishing_api.expects(:get_content_items)
              .with(document_type: "organisation", per_page: "500")
              .once
              .returns(results)

      assert(5.times { Organisation.all })
    end
  end
end
