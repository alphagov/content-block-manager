RSpec.describe AbbreviatedNumberHelper do
  include AbbreviatedNumberHelper

  describe "#abbreviated_number" do
    {
      7 => "7",
      999 => "999",
      1_000 => "1k",
      11_234 => "11.2k",
      98_731 => "98.7k",
      1_200_000 => "1.2m",
      3_450_000_000 => "3.45b",
    }.each do |number, expected|
      it "abbreviates #{number} as #{expected}" do
        expect(abbreviated_number(number)).to eq(expected)
      end
    end
  end
end
