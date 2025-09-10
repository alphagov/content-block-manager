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
      { "content_id" => SecureRandom.uuid, "title" => "Organisation B" }
    end

    let(:organisation_2) do
      { "content_id" => SecureRandom.uuid, "title" => "Organisation A" }
    end

    let(:results) do
      {
        "results" => [organisation_1, organisation_2],
      }
    end

    it "fetches organisations" do
      Services.publishing_api.expects(:get_content_items)
              .with(document_type: "organisation",
                    fields: %w[title content_id],
                    per_page: "500")
              .returns(results)

      organisations = Organisation.all

      assert_equal 2, organisations.size

      assert_equal organisations.first.id, organisation_2["content_id"]
      assert_equal organisations.first.name, organisation_2["title"]

      assert_equal organisations.second.id, organisation_1["content_id"]
      assert_equal organisations.second.name, organisation_1["title"]
    end

    it "caches results" do
      Services.publishing_api.expects(:get_content_items)
              .with(document_type: "organisation",
                    fields: %w[title content_id],
                    per_page: "500")
              .once
              .returns(results)

      assert(5.times { Organisation.all })
    end
  end

  describe "#find" do
    let(:organisation_1) { build(:organisation) }
    let(:organisation_2) { build(:organisation) }

    before do
      Organisation.expects(:all).returns([organisation_1, organisation_2])
    end

    it "returns an organisation" do
      organisation = Organisation.find(organisation_1.id)

      assert_equal organisation.id, organisation_1.id
      assert_equal organisation.name, organisation_1.name
    end

    it "returns nil if an organisation cannot be found" do
      organisation = Organisation.find(SecureRandom.uuid)

      assert_nil organisation
    end
  end
end
