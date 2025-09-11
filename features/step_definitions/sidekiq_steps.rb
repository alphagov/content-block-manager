Then(/^there should only be one job scheduled$/) do
  jobs = Sidekiq::ScheduledSet.new.select { |job| job.item["class"] == SchedulePublishingWorker.to_s }
  expect(jobs.count).to eq(1)
end

Then(/^there should be no jobs scheduled$/) do
  jobs = Sidekiq::ScheduledSet.new.select { |job| job.item["class"] == SchedulePublishingWorker.to_s }
  expect(jobs.count).to eq(0)
end
