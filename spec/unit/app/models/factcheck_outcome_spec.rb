RSpec.describe FactcheckOutcome, type: :model do
  let(:creator) { create(:user) }
  let(:outcome) { described_class.new("creator" => creator) }

  it "should get and set the performer" do
    outcome.performer = "Fred"
    expect(outcome.performer).to eq("Fred")
  end
end
