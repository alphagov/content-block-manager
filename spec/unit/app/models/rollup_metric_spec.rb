RSpec.describe RollupMetric, type: :model do
  it { is_expected.to belong_to(:document) }

  describe ".record!" do
    let(:organisation) { build(:organisation, name: "Department for Work and Pensions") }
    let(:document) { create(:document, :pension) }
    let(:rollup) do
      HostContentItem::Items::Rollup.new(views: 98_731, locations: 7, instances: 20, organisations: 1)
    end

    let!(:edition) { create(:edition, :pension, :published, document: document, lead_organisation_id: organisation.id) }

    before do
      allow(Organisation).to receive(:all).and_return([organisation])
    end

    it "records the block's rollup metrics" do
      rollup_metric = described_class.record!(document: document, rollup: rollup)

      expect(rollup_metric).to have_attributes(
        document: document,
        views: 98_731,
        locations: 7,
        instances: 20,
        organisations: 1,
      )
    end

    context "where the most recent edition is associated with a different organisation" do
      let(:newer_organisation) { build(:organisation, name: "Competition and Markets Authority") }

      before do
        edition.update!(updated_at: 1.month.ago)
        allow(Organisation).to receive(:all).and_return([organisation, newer_organisation])
        create(
          :edition, :pension, :draft,
          document: document, lead_organisation_id: newer_organisation.id, updated_at: Time.current
        )
      end

      it "records the name of that lead organisation" do
        rollup_metric = described_class.record!(document: document, rollup: rollup)

        expect(rollup_metric.lead_organisation_name).to eq(newer_organisation.name)
      end
    end

    context "when an organisation is not found" do
      before { allow(Organisation).to receive(:all).and_return([]) }

      it "records no lead organisation name" do
        rollup_metric = described_class.record!(document: document, rollup: rollup)

        expect(rollup_metric.lead_organisation_name).to be_nil
      end
    end

    it "records when the metrics were refreshed" do
      rollup_metric = described_class.record!(document: document, rollup: rollup)

      expect(rollup_metric.refreshed_at).to eq(Time.current)
    end

    context "when a rollup metric already exists for a block" do
      before do
        described_class.record!(document: document, rollup: rollup)
      end

      let(:updated_rollup) { rollup.with(views: 100_000) }

      it "updates the block's existing metrics rather than adding another row" do
        described_class.record!(document: document, rollup: updated_rollup)

        Timecop.freeze(1.hour.from_now) do
          expect {
            described_class.record!(document: document, rollup: updated_rollup)
          }.not_to change(described_class, :count)

          expect(document.reload.rollup_metric).to have_attributes(
            views: 100_000,
            refreshed_at: Time.current,
          )
        end
      end
    end

    context "when the returned rollup metrics are nils" do
      let(:empty_rollup) do
        HostContentItem::Items::Rollup.new(
          views: nil, locations: nil, instances: nil, organisations: nil,
        )
      end

      it "records zero values" do
        rollup_metric = described_class.record!(document: document, rollup: empty_rollup)

        expect(rollup_metric).to have_attributes(views: 0, locations: 0, instances: 0, organisations: 0)
      end
    end
  end
end
