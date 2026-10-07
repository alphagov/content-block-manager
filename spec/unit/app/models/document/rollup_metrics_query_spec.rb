RSpec.describe Document::RollupMetricsQuery do
  def block(title, block_type:, organisation: nil, **metrics)
    document = create(:edition, block_type, :published, title:).document
    if metrics.any?
      create(:rollup_metric, document:, lead_organisation_name: organisation, **metrics)
    end
    document
  end

  let!(:pension) do
    block(
      "Pension",
      block_type: :pension,
      organisation: "Department for Work and Pensions",
      locations: 7,
      instances: 20,
      views: 98_731,
      organisations: 3,
    )
  end

  let!(:contact) do
    block(
      "Contact",
      block_type: :contact,
      organisation: "Competition and Markets Authority",
      locations: 129,
      instances: 129,
      views: 11_234,
      organisations: 1,
    )
  end

  let!(:time_period) do
    block(
      "TimePeriod",
      block_type: :time_period,
      organisation: "HM Revenue and Customs",
      locations: 50,
      instances: 60,
      views: 500_000,
      organisations: 2,
    )
  end

  let!(:unmeasured) { block("Unmeasured", block_type: :contact) }

  before { allow(Organisation).to receive(:all).and_return([]) }

  def titles(order)
    described_class.new(order:).documents.map(&:title)
  end

  describe "#documents" do
    it "includes every block that hasn't been deleted" do
      deleted = block("Deleted", block_type: :pension, views: 1)
      deleted.soft_delete

      expect(titles(nil)).to contain_exactly("Pension", "Contact", "TimePeriod", "Unmeasured")
    end

    it "orders by views, highest first, by default" do
      expect(titles(nil)).to eq(%w[TimePeriod Pension Contact Unmeasured])
    end

    {
      "lead_organisation_name" => %w[Contact Pension TimePeriod],
      "block_type" => %w[Contact Pension TimePeriod],
      "locations" => %w[Pension TimePeriod Contact],
      "instances" => %w[Pension TimePeriod Contact],
      "views" => %w[Contact Pension TimePeriod],
      "organisations" => %w[Contact TimePeriod Pension],
    }.each do |column, ascending|
      it "orders by #{column}, ascending" do
        expect(titles(column) - %w[Unmeasured]).to eq(ascending)
      end

      it "orders by #{column}, descending" do
        expect(titles("-#{column}") - %w[Unmeasured]).to eq(ascending.reverse)
      end
    end

    %w[locations -locations views -views lead_organisation_name -lead_organisation_name].each do |order|
      it "puts blocks without metrics last when ordering by #{order}" do
        expect(titles(order).last).to eq("Unmeasured")
      end
    end

    it "orders blocks without metrics by block type like any other block" do
      expect(titles("block_type")).to eq(%w[Contact Unmeasured Pension TimePeriod])
    end

    it "falls back to the default order when the order isn't one we allow" do
      expect(titles("title; DROP TABLE documents")).to eq(%w[TimePeriod Pension Contact Unmeasured])
    end
  end

  describe "#order" do
    it "is the requested order when it's one we allow" do
      expect(described_class.new(order: "-locations").order).to eq("-locations")
    end

    it "is the default order when none is given" do
      expect(described_class.new(order: nil).order).to eq("-views")
    end

    it "is the default order when the requested order isn't one we allow" do
      expect(described_class.new(order: "embed_code").order).to eq("-views")
    end
  end
end
