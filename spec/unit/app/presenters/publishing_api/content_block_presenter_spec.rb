RSpec.describe PublishingApi::ContentBlockPresenter do
  let(:title) { "Some title" }
  let(:instructions_to_publishers) { "Some instructions" }
  let(:lead_organisation) { build(:organisation) }
  let(:details) do
    {
      "foo" => "bar",
      "something" => "else",
    }
  end
  let(:change_note) { "Some change note" }

  let(:schema_id) { "content_block_foo" }
  let(:content_id_alias) { "foo" }
  let(:edition) { build(:edition, title:, instructions_to_publishers:, details:, change_note:) }

  before do
    allow(edition).to receive(:lead_organisation).and_return(lead_organisation)
  end

  let(:presenter) { described_class.new(schema_id:, content_id_alias:, edition:) }

  describe "#present" do
    let(:result) { presenter.present }

    it "returns a hash" do
      expect(result).to be_a(Hash)
      expect(result[:schema_name]).to eq(schema_id)
      expect(result[:document_type]).to eq(schema_id)
      expect(result[:publishing_app]).to eq(ContentBlockManager::PublishingApp::CONTENT_BLOCK_MANAGER)
      expect(result[:title]).to eq(title)
      expect(result[:instructions_to_publishers]).to eq(instructions_to_publishers)
      expect(result[:content_id_alias]).to eq(content_id_alias)
      expect(result[:details]).to eq(details)
      expect(result[:links]).to eq({
        primary_publishing_organisation: [lead_organisation.id],
      })
    end

    context "when the edition has a major change" do
      before do
        edition.major_change = true
      end

      it "sets the update type to major" do
        expect(result[:update_type]).to eq("major")
      end

      it "includes the change note" do
        expect(result[:change_note]).to eq(change_note)
      end
    end

    context "when the edition does not have a major change" do
      before do
        edition.major_change = false
      end

      it "sets the update type to major" do
        expect(result[:update_type]).to eq("minor")
      end

      it "does not include the change note" do
        expect(result[:change_note]).to be_nil
      end
    end
  end
end
