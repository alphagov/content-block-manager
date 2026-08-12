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
      before { create(:user, name: "Test user") }

      it "creates document 18 with the fixture's content_id and alias" do
        described_class.seed!

        document = Document.find(described_class::DOCUMENT_ID)
        expect(document.content_id).to eq(described_class::DOCUMENT_CONTENT_ID)
        expect(document.content_id_alias).to eq(described_class::CONTENT_ID_ALIAS)
        expect(document.block_type).to eq("pension")
        expect(document.embed_code)
          .to eq("{{embed:content_block_pension:test-content-block-do-not-use}}")
      end

      it "creates a draft edition carrying the pension rate-1 amount" do
        described_class.seed!

        edition = Document.find(described_class::DOCUMENT_ID).editions.sole
        expect(edition).to be_draft
        expect(edition.details.dig("rates", "rate-1", "amount")).to eq("134.64")
        expect(edition.lead_organisation_id)
          .to eq(described_class::LEAD_ORGANISATION_ID)
      end

      it "associates the edition to the Test user via the audit trail" do
        described_class.seed!

        edition = Document.find(described_class::DOCUMENT_ID).editions.sole
        expect(edition.creator.name).to eq("Test user")
        expect(edition.versions.first.event).to eq("created")
      end

      it "is idempotent" do
        described_class.seed!

        expect { described_class.seed! }.not_to change(Document, :count)
        expect { described_class.seed! }.not_to change(Edition, :count)
      end
    end
  end
end
