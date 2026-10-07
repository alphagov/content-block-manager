RSpec.describe "host_content_metrics:refresh_rollups" do
  let(:task) { Rake::Task["host_content_metrics:refresh_rollups"] }

  let(:organisation) { build(:organisation, name: "Department for Work and Pensions") }

  let!(:pension) { create(:edition, :pension, :published, lead_organisation_id: organisation.id).document }
  let!(:contact) { create(:edition, :contact, :draft, lead_organisation_id: organisation.id).document }

  before do
    allow(Organisation).to receive(:all).and_return([organisation])
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
  end

  after do
    task.reenable
  end

  describe "when Publishing API returns each block's rollup" do
    before do
      stub_publishing_api_has_embedded_content_for_any_content_id(
        order: HostContentItem::DEFAULT_ORDER,
        rollup: { "views" => 98_731, "locations" => 7, "instances" => 20, "organisations" => 1 },
      )
    end

    it "records the rollup metrics of every block, including drafts" do
      task.invoke

      [pension, contact].each do |document|
        expect(document.reload.rollup_metric).to have_attributes(
          views: 98_731,
          locations: 7,
          instances: 20,
          organisations: 1,
          lead_organisation_name: "Department for Work and Pensions",
          refreshed_at: Time.current,
        )
      end
    end

    it "doesn't refresh deleted blocks" do
      deleted = create(:edition, :pension, :published, lead_organisation_id: organisation.id).document
      deleted.soft_delete

      task.invoke

      expect(RollupMetric.find_by(document_id: deleted.id)).to be_nil
    end

    it "logs its progress" do
      task.invoke

      expect(Rails.logger).to have_received(:info).with(/Refreshing rollup metrics for 2 blocks/)
      expect(Rails.logger).to have_received(:info).with(/Refreshed 2 blocks, 0 failed/)
    end
  end

  describe "when Publishing API fails for one of the blocks" do
    let(:error) { GdsApi::HTTPErrorResponse.new(500, "Publishing API is unavailable") }

    before do
      allow(HostContentItem).to receive(:rollup_for).and_call_original
      allow(HostContentItem).to receive(:rollup_for).with(pension).and_raise(error)
      stub_publishing_api_has_embedded_content_for_any_content_id(
        order: HostContentItem::DEFAULT_ORDER,
        rollup: { "views" => 11_234, "locations" => 129, "instances" => 129, "organisations" => 1 },
      )
    end

    it "still refreshes the other blocks" do
      task.invoke

      expect(contact.reload.rollup_metric).to have_attributes(views: 11_234)
    end

    it "leaves the failed block's previous metrics in place" do
      create(:rollup_metric, document: pension, views: 500, refreshed_at: 1.day.ago)

      task.invoke

      expect(pension.reload.rollup_metric).to have_attributes(views: 500, refreshed_at: 1.day.ago)
    end

    it "logs the failure" do
      task.invoke

      expect(Rails.logger).to have_received(:error)
        .with(/Failed to refresh #{pension.content_id}: .*Publishing API is unavailable/)
      expect(Rails.logger).to have_received(:info).with(/Refreshed 1 block, 1 failed/)
    end
  end

  describe "when something other than Publishing API goes wrong" do
    before do
      allow(HostContentItem).to receive(:rollup_for).and_raise(NoMethodError, "a bug")
    end

    it "stops, rather than hiding the problem" do
      expect { task.invoke }.to raise_error(NoMethodError, "a bug")
    end
  end
end
