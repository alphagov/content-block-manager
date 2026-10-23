RSpec.describe PublishingApi::V2ContentBlockPresenter do
  let(:title) { "Some title" }
  let(:instructions_to_publishers) { "Some instructions" }
  let(:lead_organisation) { build(:organisation) }

  let(:document_type) { "content_block_foo" }
  let(:content_id_alias) { "foo" }
  let(:edition) do
    create(
      :v2_time_period_edition,
      description: "Foo text",
      date_range: build(:v2_time_period_date_range),
      lead_organisation_id: lead_organisation.id,
      instructions_to_publishers:,
      title:,
    )
  end

  before do
    allow(edition).to receive(:lead_organisation).and_return(lead_organisation)
  end

  let(:presenter) { described_class.new(document_type:, content_id_alias:, edition:) }

  describe "#present" do
    let(:result) { presenter.present }

    it "returns a hash" do
      expect(result).to eq({
        schema_name: "content_block",
        document_type:,
        publishing_app: ContentBlockManager::PublishingApp::CONTENT_BLOCK_MANAGER,
        title:,
        instructions_to_publishers:,
        content_id_alias:,
        change_note: nil,
        details: edition.to_details,
        update_type: "minor",
        links: {
          primary_publishing_organisation: [lead_organisation.id],
        },
      })
    end
  end
end
