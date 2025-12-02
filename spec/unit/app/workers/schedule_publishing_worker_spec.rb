RSpec.describe SchedulePublishingWorker do
  include SidekiqTestHelpers

  # Suppress noisy Sidekiq logging in the test output
  before do
    Sidekiq.configure_client do |cfg|
      cfg.logger.level = ::Logger::WARN
    end
  end

  describe "#perform" do
    it "publishes a scheduled edition" do
      document = create(:document, :pension)
      edition = create(:edition, document:, state: "scheduled", scheduled_publication: Time.zone.now + 1.day)

      publish_service_mock = double
      allow(publish_service_mock).to receive(:verify)
      allow(publish_service_mock).to receive(:call).with(edition).and_return(nil)

      expect(PublishEditionService).to receive(:new).and_return(publish_service_mock)

      SchedulePublishingWorker.new.perform(edition.id)
      publish_service_mock.verify
    end

    it "raises an error if the edition cannot be published" do
      document = create(:document, :pension)
      edition = create(:edition, document:, state: "scheduled", scheduled_publication: 7.days.since(Time.zone.now).to_date)

      publish_service_mock = double
      exception = PublishEditionService::PublishingFailureError.new(
        "Could not publish #{document.content_id} because: Some backend error",
      )

      allow_any_instance_of(PublishEditionService).to receive(:call).and_raise(exception)
      allow(publish_service_mock).to receive(:verify)

      expect { SchedulePublishingWorker.new.perform(edition.id) }.to raise_error(
        SchedulePublishingWorker::SchedulingFailure,
        "Could not publish #{document.content_id} because: Some backend error",
      )
      publish_service_mock.verify
    end

    it "returns without consequence if the edition is already published" do
      document = create(:document, :pension)
      edition = create(:edition, document:, state: "published")

      expect(PublishEditionService).to receive(:new).never
      allow_any_instance_of(PublishEditionService).to receive(:call).never

      SchedulePublishingWorker.new.perform(edition.id)
    end

    it "returns without consequence if the edition is deleted" do
      document = create(:document, :pension)
      edition = create(:edition, document:, state: :deleted, scheduled_publication: 1.day.from_now)
      publish_edition_service_mock = spy
      allow(PublishEditionService).to receive(:new).and_return(publish_edition_service_mock)

      SchedulePublishingWorker.new.perform(edition.id)

      aggregate_failures do
        expect(PublishEditionService).not_to have_received(:new)
        expect(publish_edition_service_mock).not_to have_received(:call)
      end
    end
  end

  describe ".queue" do
    it "queues a job for a scheduled edition" do
      document = create(:document, :pension)
      edition = create(
        :edition,
        document:, state: "scheduled",
        scheduled_publication: 1.day.from_now
      )

      SchedulePublishingWorker.queue(edition)

      expect(job = SchedulePublishingWorker.jobs.last).to be
      expect(job["args"].first).to eq(edition.id)
      expect(job["at"].to_i).to eq(edition.scheduled_publication.to_i)
    end
  end

  describe ".dequeue" do
    it "removes a job for a scheduled edition" do
      document = create(:document, :pension)
      edition = create(
        :edition,
        document:,
        state: "scheduled",
        scheduled_publication: 1.day.from_now,
      )

      control_document = create(:document, :pension)
      control_edition = create(
        :edition,
        document: control_document,
        state: "scheduled",
        scheduled_publication: 1.day.from_now,
      )

      with_real_sidekiq do
        SchedulePublishingWorker.queue(edition)
        SchedulePublishingWorker.queue(control_edition)

        expect(Sidekiq::ScheduledSet.new.size).to eq(2)

        SchedulePublishingWorker.dequeue(edition)

        expect(Sidekiq::ScheduledSet.new.size).to eq(1)

        control_job = Sidekiq::ScheduledSet.new.first

        expect(control_edition.id).to eq(control_job.[]("args").first)
        expect(control_edition.scheduled_publication.to_i).to eq(control_job.at.to_i)
      end
    end
  end

  describe ".dequeue_all" do
    it "removes all content block publishing jobs" do
      document_1 = create(:document, :pension)
      edition_1 = create(
        :edition,
        document: document_1,
        state: "scheduled",
        scheduled_publication: 1.day.from_now,
      )

      document_2 = create(:document, :pension)
      edition_2 = create(
        :edition,
        document: document_2,
        state: "scheduled",
        scheduled_publication: 1.day.from_now,
      )

      with_real_sidekiq do
        SchedulePublishingWorker.queue(edition_1)
        SchedulePublishingWorker.queue(edition_2)

        expect(Sidekiq::ScheduledSet.new.size).to eq(2)

        SchedulePublishingWorker.dequeue_all

        expect(Sidekiq::ScheduledSet.new.size).to eq(0)
      end
    end
  end

  describe ".queue_size" do
    it "returns the number of queued SchedulePublishingWorker jobs" do
      with_real_sidekiq do
        SchedulePublishingWorker.perform_at(1.day.from_now, "null")
        expect(SchedulePublishingWorker.queue_size).to eq(1)

        SchedulePublishingWorker.perform_at(2.days.from_now, "null")
        expect(SchedulePublishingWorker.queue_size).to eq(2)
      end
    end
  end

  describe ".queued_edition_ids" do
    it "returns the edition ids of the currently queued jobs" do
      with_real_sidekiq do
        SchedulePublishingWorker.perform_at(1.day.from_now, "3")
        SchedulePublishingWorker.perform_at(2.days.from_now, "6")

        expect(SchedulePublishingWorker.queued_edition_ids).to contain_exactly(*%w[3 6])
      end
    end
  end
end
