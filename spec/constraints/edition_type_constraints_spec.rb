RSpec.describe EditionTypeConstraints do
  let(:edition) { create(:v2_time_period_edition) }

  describe "#matches?" do
    it "returns true when the edition is the same type the constraint is initialised for" do
      constraint = described_class.new("V2::TimePeriodEdition")
      expect(constraint.matches?(request_for(id: edition.id.to_s))).to be true
    end

    it "returns false when the edition is not the same type the constraint is initialised for" do
      constraint = described_class.new("Edition")
      expect(constraint.matches?(request_for(id: edition.id.to_s))).to be false
    end

    it "will use :edition_id over :id for nested queries" do
      constraint = described_class.new("V2::TimePeriodEdition")
      expect(constraint.matches?(request_for(id: "99999999",
                                             edition_id: edition.id.to_s,
                                             some_other_id: "9999999"))).to be true
    end

    it "will not repeatedly query the database for the edition type in a single request" do
      request = request_for(id: edition.id.to_s)

      expect(V2::Edition).to receive(:where).once.and_call_original

      described_class.new("Edition").matches?(request)
      expect(described_class.new("V2::TimePeriodEdition").matches?(request)).to be true
    end

    it "returns false for a request lacking :edition_id or :id" do
      constraint = described_class.new("V2::TimePeriodEdition")
      expect(constraint.matches?(request_for(foo: "bar"))).to be false
    end

    it "returns false where edition_id is invalid" do
      constraint = described_class.new("V2::TimePeriodEdition")
      expect(constraint.matches?(request_for(id: "invalid"))).to be false
    end
  end
end
