RSpec.describe PublishEditionService do
  describe "#call" do
    let(:content_id) { "49453854-d8fd-41da-ad4c-f99dbac601c3" }
    let(:schema) { build(:schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } }) }
    let(:document) { create(:document, :pension, content_id:, sluggable_string: "some-edition-title") }
    let(:major_change) { true }
    let(:organisation) { build(:organisation) }
    let(:edition) do
      create(
        :edition,
        document:,
        details: { "foo" => "Foo text", "bar" => "Bar text" },
        lead_organisation_id: organisation.id,
        instructions_to_publishers: "instructions",
        title: "Some Edition Title",
        change_note: "Something changed publicly",
        major_change:,
      )
    end

    before do
      allow(Schema).to receive(:find_by_block_type).and_return(schema)
      allow(Organisation).to receive(:all).and_return([organisation])
      allow(Services.publishing_api).to receive(:put_content)
      allow(Services.publishing_api).to receive(:publish)
    end

    it "returns a ContentBlockEdition" do
      result = PublishEditionService.new.call(edition)

      expect(result).to be_a(Edition)
    end

    it "publishes the Edition" do
      expect(SchedulePublishingWorker).to receive(:dequeue).never

      PublishEditionService.new.call(edition)
      expect(edition.state).to eq("published")
      expect(document.live_edition_id).to eq(edition.id)
    end

    it "creates an Edition in the Publishing API" do
      presenter_stub = double(PublishingApi::ContentBlockPresenter)
      presented_hash = double(hash: {})
      expect(PublishingApi::ContentBlockPresenter).to receive(:new)
                                                  .with(
                                                    schema_id: schema.id,
                                                    content_id_alias: "some-edition-title",
                                                    edition: edition,
                                                  )
                                                  .and_return(presenter_stub)
      expect(presenter_stub).to receive(:present).and_return(presented_hash)

      expect(Services.publishing_api).to receive(:put_content).with(content_id, presented_hash)

      expect(Services.publishing_api).to receive(:publish).with(content_id)

      PublishEditionService.new.call(edition)

      expect(edition.state).to eq("published")
      expect(document.live_edition_id).to eq(edition.id)
    end

    it "rolls back the ContentBlockEdition and ContentBlockDocument if the publishing API request fails" do
      allow(Services.publishing_api).to receive(:publish)
                                    .and_raise(
                                      GdsApi::HTTPErrorResponse.new(
                                        422,
                                        "An internal error message",
                                        "error" => { "message" => "Some backend error" },
                                      ),
                                    )

      expect(Services.publishing_api).to receive(:discard_draft).with(content_id)

      expect(edition.state).to eq("draft")
      expect(document.live_edition_id).to be_nil

      expect {
        PublishEditionService.new.call(edition)
      }.to raise_error(PublishEditionService::PublishingFailureError)

      expect(edition.state).to eq("draft")
      expect(document.live_edition_id).to be_nil
    end

    it "discards the latest draft if the publish request fails" do
      expect(Services.publishing_api).to receive(:put_content)
      expect(Services.publishing_api).to receive(:publish).and_raise(
        GdsApi::HTTPErrorResponse.new(
          422,
          "An internal error message",
          "error" => { "message" => "Some backend error" },
        ),
      )

      expect(Services.publishing_api).to receive(:discard_draft).with(content_id)

      expect { PublishEditionService.new.call(edition) }.to raise_error(
        PublishEditionService::PublishingFailureError, "Could not publish #{content_id} because: An internal error message"
      )

      expect(edition.state).to eq("draft")
      expect(document.live_edition_id).to be_nil
    end

    it "supersedes any previously scheduled editions" do
      scheduled_editions = create_list(:edition, 2,
                                       document:,
                                       scheduled_publication: 7.days.from_now,
                                       lead_organisation_id: organisation.id,
                                       state: "scheduled")

      scheduled_editions.each do |scheduled_edition|
        expect(SchedulePublishingWorker).to receive(:dequeue).with(scheduled_edition)
      end

      PublishEditionService.new.call(edition)

      scheduled_editions.each do |scheduled_edition|
        expect(scheduled_edition.reload).to be_superseded
      end
    end
  end
end
