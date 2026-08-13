require "spec_helper"
require "govuk_e2e/content_block_manager/fixtures"

RSpec.describe GovukE2e::ContentBlockManager::Fixtures do
  describe ".seed!" do
    context "when the Test user is absent" do
      it "raises a helpful error" do
        expect { described_class.seed! }
          .to raise_error(/Test user.*Run `rake db:seed`/m)
      end
    end

    context "when the Test user is present" do
      before do
        create(:user, name: "Test user")
        lead_organisation =
          build(:organisation, id: described_class::LEAD_ORGANISATION_ID)
        allow(Organisation).to receive(:all).and_return([lead_organisation])
        allow(Public::Services.publishing_api).to receive(:put_content)
        allow(Public::Services.publishing_api).to receive(:publish)
      end

      it "creates document 18 with the fixture's content_id and alias" do
        described_class.seed!

        document = Document.find(described_class::DOCUMENT_ID)
        expect(document.content_id).to eq(described_class::DOCUMENT_CONTENT_ID)
        expect(document.content_id_alias).to eq(described_class::CONTENT_ID_ALIAS)
        expect(document.block_type).to eq("pension")
        expect(document.embed_code)
          .to eq("{{embed:content_block_pension:test-content-block-do-not-use}}")
      end

      it "publishes an edition carrying the pension rate-1 amount" do
        described_class.seed!

        edition = Document.find(described_class::DOCUMENT_ID).editions.sole
        expect(edition).to be_published
        expect(edition.details.dig("rates", "rate-1", "amount")).to eq("134.64")
        expect(edition.lead_organisation_id)
          .to eq(described_class::LEAD_ORGANISATION_ID)
      end

      it "sends the published block to the Publishing API" do
        described_class.seed!

        expect(Public::Services.publishing_api)
          .to have_received(:put_content)
            .with(described_class::DOCUMENT_CONTENT_ID, anything)
        expect(Public::Services.publishing_api)
          .to have_received(:publish).with(described_class::DOCUMENT_CONTENT_ID)
      end

      it "associates the edition to the Test user via the audit trail" do
        described_class.seed!

        edition = Document.find(described_class::DOCUMENT_ID).editions.sole
        expect(edition.creator.name).to eq("Test user")
        expect(edition.versions.last.event).to eq("created")
      end

      it "is idempotent" do
        described_class.seed!

        expect { described_class.seed! }.not_to change(Document, :count)
        expect { described_class.seed! }.not_to change(Edition, :count)
      end
    end

    context "when the lead organisation is absent from the Publishing API" do
      before do
        create(:user, name: "Test user")
        lead_organisation =
          build(:organisation, id: described_class::LEAD_ORGANISATION_ID)
        allow(Organisation).to receive(:all).and_return([lead_organisation])
        allow(Public::Services.publishing_api).to receive(:put_content)
        allow(Public::Services.publishing_api).to receive(:publish)
      end

      it "publishes the lead organisation to the Publishing API so the block can resolve it" do
        described_class.seed!

        expect(Public::Services.publishing_api)
          .to have_received(:put_content)
          .with(
            described_class::LEAD_ORGANISATION_ID,
            hash_including("document_type" => "organisation"),
          )
        expect(Public::Services.publishing_api)
          .to have_received(:publish)
          .with(described_class::LEAD_ORGANISATION_ID, "major")
      end

      it "busts the organisations cache so Organisation.all reflects the new org" do
        expect(Rails.cache).to receive(:delete).with("organisations")

        described_class.seed!
      end
    end
  end
end
