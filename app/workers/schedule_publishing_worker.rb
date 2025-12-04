require "sidekiq/api"

# SchedulePublishingWorker is a job that is scheduled by the `ScheduleEditionService`.
# It is never executed immediately but uses the Sidekiq delay mechanism to
# execute at the time the edition should be published.
class SchedulePublishingWorker < WorkerBase
  SchedulingFailure = Class.new(StandardError)

  class << self
    def queue(edition)
      perform_at(edition.scheduled_publication, edition.id)
    end

    def dequeue(edition)
      Sidekiq::ScheduledSet
        .new
        .select { |joby| joby["class"] == name && joby.args[0] == edition.id }
        .map(&:delete)
    end

    # Only used by the publishing:scheduled:requeue_all_jobs rake task.
    def dequeue_all
      queued_jobs.map(&:delete)
    end

    def queue_size
      queued_jobs.size
    end

    def queued_edition_ids
      queued_jobs.map { |job| job["args"][0] }
    end

  private

    def queued_jobs
      Sidekiq::ScheduledSet.new.select { |job| job["class"] == name }
    end
  end

  sidekiq_options queue: :content_block_publishing

  def perform(edition_id)
    logger.info("performing content block publishing job for Edition #{edition_id}")
    edition = Edition.find(edition_id)
    return unless edition.scheduled?

    Edition::HasAuditTrail.acting_as(publishing_robot) do
      PublishEditionService.new.call(edition)
    end
  rescue PublishEditionService::PublishingFailureError => e
    raise SchedulingFailure, e.message
  end

private

  def publishing_robot
    User.where(name: "Scheduled Publishing Robot", uid: nil).first
  end
end
