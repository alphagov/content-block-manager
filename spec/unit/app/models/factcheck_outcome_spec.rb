RSpec.describe FactcheckOutcome, type: :model do
  let(:creator) { create(:user) }
  let(:outcome) { described_class.new("creator" => creator) }

  it "should get and set the reviewer" do
    outcome.reviewer = "Fred"
    expect(outcome.reviewer).to eq("Fred")
  end
end
