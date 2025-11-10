RSpec.describe EmbeddedObjectImmutabilityCheck do
  let(:field_reference) { %w[foo bar baz] }
  let(:checker) { EmbeddedObjectImmutabilityCheck.new(edition:, field_reference:) }

  describe "#can_be_deleted?" do
    describe "when an edition is given" do
      let(:edition) { build(:edition, :contact, details:) }

      describe "and something exists in the field reference" do
        let(:details) do
          {
            "foo" => {
              "bar" => {
                "baz" => [
                  { "title" => "Item 1" },
                  { "title" => "Item 2" },
                ],
              },
            },
          }
        end

        it "returns false if an item exists at that index" do
          expect(checker.can_be_deleted?(0)).to eq(false)
          expect(checker.can_be_deleted?(1)).to eq(false)
        end

        it "returns true if an item does not exist at that index" do
          expect(checker.can_be_deleted?(2)).to eq(true)
        end
      end

      describe "and nothing exists in the field reference" do
        let(:details) { {} }

        it "returns true" do
          expect(checker.can_be_deleted?(0)).to eq(true)
        end
      end
    end

    describe "when no edition is given" do
      let(:edition) { nil }

      it "returns true" do
        expect(checker.can_be_deleted?(0)).to eq(true)
      end
    end
  end
end
