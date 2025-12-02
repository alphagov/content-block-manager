class DeleteEditionService
  include Dequeueable

  def call(edition)
    SchedulePublishingWorker.dequeue(edition)
  end
end
