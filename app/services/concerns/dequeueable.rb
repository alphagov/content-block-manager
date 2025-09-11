module Dequeueable
  extend ActiveSupport::Concern

  def dequeue_all_previously_queued_editions(edition)
    edition.document.editions.where(state: :scheduled).find_each do |ed|
      next if edition.id == ed.id

      SchedulePublishingWorker.dequeue(ed)
      ed.supersede!
    end
  end
end
