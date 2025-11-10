RSpec.describe Organisation do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
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
      allow(Services.publishing_api).to receive(:get_content_items)
              .with(document_type: "organisation",
                    fields: %w[title content_id],
                    per_page: "500")
              .and_return(results)

      organisations = Organisation.all

      expect(organisations.size).to eq(2)

      expect(organisation_2.[]("content_id")).to eq(organisations.first.id)
      expect(organisation_2.[]("title")).to eq(organisations.first.name)

      expect(organisation_1.[]("content_id")).to eq(organisations.second.id)
      expect(organisation_1.[]("title")).to eq(organisations.second.name)
    end

    it "caches results" do
      allow(Services.publishing_api).to receive(:get_content_items)
              .with(document_type: "organisation",
                    fields: %w[title content_id],
                    per_page: "500")
              .once
              .and_return(results)

      assert(5.times { Organisation.all })
    end
  end

  describe "#find" do
    let(:organisation_1) { build(:organisation) }
    let(:organisation_2) { build(:organisation) }

    before do
      allow(Organisation).to receive(:all).and_return([organisation_1, organisation_2])
    end

    it "returns an organisation" do
      organisation = Organisation.find(organisation_1.id)

      expect(organisation_1.id).to eq(organisation.id)
      expect(organisation_1.name).to eq(organisation.name)
    end

    it "returns nil if an organisation cannot be found" do
      organisation = Organisation.find(SecureRandom.uuid)

      expect(organisation).to be_nil
    end
  end
end
