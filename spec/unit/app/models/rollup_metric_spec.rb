RSpec.describe RollupMetric, type: :model do
  it { is_expected.to belong_to(:document) }

  describe ".record!" do
    let(:organisation) { build(:organisation, name: "Department for Work and Pensions") }
    let(:document) { create(:document, :pension) }
    let(:rollup) do
      HostContentItem::Items::Rollup.new(views: 98_731, locations: 7, instances: 20, organisations: 1)
    end

    before do
      allow(Organisation).to receive(:all).and_return([organisation])
      create(:edition, :pension, :published, document:, lead_organisation_id: organisation.id)
    end

    it "records the block's rollup metrics" do
      rollup_metric = described_class.record!(document:, rollup:)

      expect(rollup_metric).to have_attributes(
        document:,
        views: 98_731,
        locations: 7,
        instances: 20,
        organisations: 1,
      )
    end

    it "records the name of the lead organisation of the block's most recent edition" do
      newer_organisation = build(:organisation, name: "Competition and Markets Authority")
      allow(Organisation).to receive(:all).and_return([organisation, newer_organisation])
      create(
        :edition, :pension, :draft,
        document:, lead_organisation_id: newer_organisation.id, updated_at: 1.minute.from_now
      )

      rollup_metric = described_class.record!(document:, rollup:)

      expect(rollup_metric.lead_organisation_name).to eq("Competition and Markets Authority")
    end

    it "records when the metrics were refreshed" do
      rollup_metric = described_class.record!(document:, rollup:)

      expect(rollup_metric.refreshed_at).to eq(Time.current)
    end

    it "updates the block's existing metrics rather than adding another row" do
      described_class.record!(document:, rollup:)

      Timecop.freeze(1.hour.from_now) do
        updated_rollup = rollup.with(views: 100_000)

        expect {
          described_class.record!(document:, rollup: updated_rollup)
        }.not_to change(described_class, :count)

        expect(document.reload.rollup_metric).to have_attributes(
          views: 100_000,
          refreshed_at: Time.current,
        )
      end
    end

    it "records missing metrics as zero" do
      empty_rollup = HostContentItem::Items::Rollup.new(
        views: nil, locations: nil, instances: nil, organisations: nil,
      )

      rollup_metric = described_class.record!(document:, rollup: empty_rollup)

      expect(rollup_metric).to have_attributes(views: 0, locations: 0, instances: 0, organisations: 0)
    end

    it "records no lead organisation name when the organisation isn't known" do
      allow(Organisation).to receive(:all).and_return([])

      rollup_metric = described_class.record!(document:, rollup:)

      expect(rollup_metric.lead_organisation_name).to be_nil
    end
  end

  describe ".oldest_refreshed_at" do
    it "is when the least recently refreshed block's metrics were refreshed" do
      create(:rollup_metric, refreshed_at: 2.hours.ago)
      create(:rollup_metric, refreshed_at: 3.days.ago)
      create(:rollup_metric, refreshed_at: 1.minute.ago)

      expect(described_class.oldest_refreshed_at).to eq(3.days.ago)
    end

    it "ignores the metrics of deleted blocks, which are no longer refreshed" do
      create(:rollup_metric, refreshed_at: 2.hours.ago)
      create(:rollup_metric, refreshed_at: 3.days.ago).document.soft_delete

      expect(described_class.oldest_refreshed_at).to eq(2.hours.ago)
    end

    it "is nil when no metrics have been recorded" do
      expect(described_class.oldest_refreshed_at).to be_nil
    end
  end
end
