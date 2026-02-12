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
      expect(result).to eq({
        schema_name: schema_id,
        document_type: schema_id,
        publishing_app: ContentBlockManager::PublishingApp::CONTENT_BLOCK_MANAGER,
        title:,
        instructions_to_publishers:,
        content_id_alias:,
        base_path: "/content-blocks/#{schema_id}/#{content_id_alias}",
        change_note:,
        details:,
        update_type: "major",
        links: {
          primary_publishing_organisation: [lead_organisation.id],
        },
        routes: [
          {
            path: "/content-blocks/#{schema_id}/#{content_id_alias}",
            type: "exact",
          },
        ],
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

    PublishingApi::ContentBlockPresenter::LOCAL_SCHEMAS.each do |schema|
      context "when the schema is #{schema}" do
        let(:schema_id) { schema }

        it "returns the generic schema name" do
          expect(result[:schema_name]).to eq("content_block")
        end
      end
    end
  end
end
