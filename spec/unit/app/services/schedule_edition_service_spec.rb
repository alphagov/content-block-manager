RSpec.describe ScheduleEditionService do
  let(:content_id) { SecureRandom.uuid }
  let(:organisation) { build(:organisation) }
  let(:schema) { build(:schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } }) }

  let(:edition) do
    create(:edition,
           state: :awaiting_factcheck,
           document: create(:document, :pension, content_id:),
           details: { "foo" => "Foo text", "bar" => "Bar text" },
           scheduled_publication: Time.zone.parse("2034-09-02T10:05:00"),
           lead_organisation_id: organisation.id)
  end

  before do
    allow(DomainEvent).to receive(:record)
    allow(Version).to receive(:increment_for_edition)
    allow(Schema).to receive(:find_by_block_type).and_return(schema)
    stub_publishing_api_has_embedded_content(content_id:, total: 0, results: [], order: HostContentItem::DEFAULT_ORDER)
    allow(Organisation).to receive(:all).and_return([organisation])
  end

  describe "#call" do
    it "schedules a new Edition via the Content Block Worker" do
      expect(SchedulePublishingWorker).to receive(:dequeue).never

      expect(SchedulePublishingWorker).to receive(:queue).with(
        having_attributes(
          id: edition.id,
          scheduled_publication: edition.scheduled_publication,
          scheduled?: true,
        ),
      )

      updated_edition = ScheduleEditionService
        .new
        .call(edition)

      expect(updated_edition.scheduled?).to be_truthy
    end

    it "supersedes any previously scheduled editions" do
      scheduled_editions = create_list(:edition, 2,
                                       document: edition.document,
                                       scheduled_publication: 7.days.from_now,
                                       lead_organisation_id: organisation.id,
                                       state: "scheduled")

      expect(SchedulePublishingWorker).to receive(:queue).with(having_attributes(id: edition.id))

      scheduled_editions.each do |scheduled_edition|
        expect(SchedulePublishingWorker).to receive(:dequeue).with(scheduled_edition)
      end

      ScheduleEditionService
        .new
        .call(edition)

      scheduled_editions.each do |scheduled_edition|
        expect(scheduled_edition.reload).to be_superseded
      end
    end

    it "does not persist the changes if the Worker request fails" do
      exception = GdsApi::HTTPErrorResponse.new(
        422,
        "An internal error message",
        "error" => { "message" => "Some backend error" },
      )

      expect(SchedulePublishingWorker).to receive(:queue).and_raise(exception)

      expect {
        updated_edition = ScheduleEditionService
          .new
          .call(edition)

        expect(updated_edition.draft?).to be_truthy
        expect(updated_edition.scheduled_publication).to be_nil
      }.to raise_error(GdsApi::HTTPErrorResponse)
    end

    it "does not schedule the edition if the Whitehall creation fails" do
      exception = ArgumentError.new("Cannot find schema for block_type")

      expect(SchedulePublishingWorker).to receive(:queue).never

      expect(edition).to receive(:schedule!).and_raise(exception)

      expect {
        ScheduleEditionService.new.call(edition)
      }.to raise_error(ArgumentError)
    end

    it "queues publishing intents for dependent content" do
      dependent_content =
        [
          {
            "title" => "Content title",
            "document_type" => "document",
            "base_path" => "/host-document",
            "content_id" => "1234abc",
            "publishing_app" => "example-app",
            "primary_publishing_organisation" => {
              "content_id" => "456abc",
              "title" => "Organisation",
              "base_path" => "/organisation/org",
            },
          },
        ]

      stub_publishing_api_has_embedded_content(content_id:, total: 0, results: dependent_content, order: HostContentItem::DEFAULT_ORDER)

      expect(PublishIntentWorker).to receive(:perform_async).with(
        "/host-document",
        Time.zone.local(2034, 9, 2, 10, 5, 0).to_s,
      ).once

      ScheduleEditionService
        .new
        .call(edition)
    end
  end
end
