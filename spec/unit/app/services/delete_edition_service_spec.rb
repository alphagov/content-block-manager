RSpec.describe DeleteEditionService do
  describe "#call" do
    let(:document) { create(:document) }
    let(:edition) { create(:edition, document: document, id: 345) }
    let(:scheduled_set) { double }
    let(:job) { spy }

    before do
      allow(Sidekiq::ScheduledSet).to receive(:new).and_return(scheduled_set)
      allow(scheduled_set).to receive(:select).and_return([job])

      SchedulePublishingWorker.perform_async(edition.id)
    end

    it "dequeues deleted editions" do
      described_class.new.call(edition)

      expect(job).to have_received(:delete)
    end
  end
end
