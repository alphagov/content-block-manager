class ScheduleEditionService
  include Dequeueable

  def call(edition)
    schedule_with_rollback do
      edition
    end
    send_publish_intents_for_host_documents(edition: edition)
    edition
  end

private

  def schedule_with_rollback
    raise ArgumentError, "Local database changes not given" unless block_given?

    ActiveRecord::Base.transaction do
      edition = yield

      edition.schedule! unless edition.scheduled?

      dequeue_all_previously_queued_editions(edition)
      SchedulePublishingWorker.queue(edition)
    end
  end

  def send_publish_intents_for_host_documents(edition:)
    host_content_items = HostContentItem.for_document(edition.document)
    host_content_items.each do |host_content_item|
      PublishIntentWorker.perform_async(
        host_content_item.base_path,
        host_content_item.publishing_app,
        edition.scheduled_publication.to_s,
      )
    end
  end
end
