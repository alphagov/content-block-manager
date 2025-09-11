require "test_helper"

class SchedulePublishingWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include SidekiqTestHelpers

  # Suppress noisy Sidekiq logging in the test output
  setup do
    Sidekiq.configure_client do |cfg|
      cfg.logger.level = ::Logger::WARN
    end
  end

  describe "#perform" do
    it "publishes a scheduled edition" do
      document = create(:document, :pension)
      edition = create(:edition, document:, state: "scheduled", scheduled_publication: Time.zone.now)

      publish_service_mock = Minitest::Mock.new
      PublishEditionService.expects(:new).returns(publish_service_mock)
      publish_service_mock.expect :call, nil, [edition]

      SchedulePublishingWorker.new.perform(edition.id)

      publish_service_mock.verify
    end

    it "raises an error if the edition cannot be published" do
      document = create(:document, :pension)
      edition = create(:edition, document:, state: "scheduled", scheduled_publication: 7.days.since(Time.zone.now).to_date)

      publish_service_mock = Minitest::Mock.new

      exception = PublishEditionService::PublishingFailureError.new(
        "Could not publish #{document.content_id} because: Some backend error",
      )

      PublishEditionService.any_instance.stubs(:call).raises(exception)

      assert_raises(SchedulePublishingWorker::SchedulingFailure, "Could not publish #{document.content_id} because: Some backend error") do
        SchedulePublishingWorker.new.perform(edition.id)
      end
      publish_service_mock.verify
    end

    it "returns without consequence if the edition is already published" do
      document = create(:document, :pension)
      edition = create(:edition, document:, state: "published")

      PublishEditionService.expects(:new).never
      PublishEditionService.any_instance.expects(:call).never

      SchedulePublishingWorker.new.perform(edition.id)
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

      assert job = SchedulePublishingWorker.jobs.last
      assert_equal edition.id, job["args"].first
      assert_equal edition.scheduled_publication.to_i, job["at"].to_i
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

        assert_equal 2, Sidekiq::ScheduledSet.new.size

        SchedulePublishingWorker.dequeue(edition)

        assert_equal 1, Sidekiq::ScheduledSet.new.size

        control_job = Sidekiq::ScheduledSet.new.first

        assert_equal control_job["args"].first, control_edition.id
        assert_equal control_job.at.to_i, control_edition.scheduled_publication.to_i
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

        assert_equal 2, Sidekiq::ScheduledSet.new.size

        SchedulePublishingWorker.dequeue_all

        assert_equal 0, Sidekiq::ScheduledSet.new.size
      end
    end
  end

  describe ".queue_size" do
    it "returns the number of queued ContentBlockPublishingWorker jobs" do
      with_real_sidekiq do
        SchedulePublishingWorker.perform_at(1.day.from_now, "null")
        assert_equal 1, SchedulePublishingWorker.queue_size

        SchedulePublishingWorker.perform_at(2.days.from_now, "null")
        assert_equal 2, SchedulePublishingWorker.queue_size
      end
    end
  end

  describe ".queued_edition_ids" do
    it "returns the edition ids of the currently queued jobs" do
      with_real_sidekiq do
        SchedulePublishingWorker.perform_at(1.day.from_now, "3")
        SchedulePublishingWorker.perform_at(2.days.from_now, "6")

        assert_same_elements %w[3 6], SchedulePublishingWorker.queued_edition_ids
      end
    end
  end
end
