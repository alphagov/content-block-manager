RSpec.describe DetailsValidator do
  describe "tax schema" do
    let(:document) { build(:document, :tax) }

    let(:things_taxed) {}
    let(:tax_type) { "Tax" }

    let(:details) do
      {
        abbreviation: "TAX",
        description: "Some description",
        synonym: "Some synonym",
        tax_type:,
        things_taxed:,
      }
    end

    subject { build(:edition, :tax, details:, document:) }

    before do
      subject.valid?
    end

    let(:errors) { subject.errors }

    context "when the tax is valid" do
      it { is_expected.to be_valid }
    end

    context "when tax_type is blank" do
      let(:tax_type) { "" }

      it { is_expected.not_to be_valid }

      it "adds an error to the tax_type field" do
        expect(errors[:details_tax_type]).to include("Tax type cannot be blank")
      end
    end

    context "when things_taxed is included" do
      let(:things_taxed) do
        {
          "thing-1": {
            title:,
            type:,
            rates:,
          },
        }
      end

      let(:title) { "Thing 1" }
      let(:type) { "Income" }

      let(:rates) do
        [
          {
            name: rate_name,
            value: rate_value,
            bands:,
          },
        ]
      end

      let(:rate_name) { "Rate 1" }
      let(:rate_value) { "£100" }

      let(:bands) { [band] }

      let(:band) do
        {
          name: band_name,
          lower_threshold: {
            show: true,
            value: "£1000",
          },
          upper_threshold: {
            show: true,
            value: "£1500",
          },
        }
      end

      let(:band_name) { "Band 1" }

      context "when the objects are valid" do
        it { is_expected.to be_valid }
      end

      context "when title is blank" do
        let(:title) { "" }

        it { is_expected.not_to be_valid }

        it "adds an error to the titke field" do
          expect(errors[:details_things_taxed_title]).to include("Title cannot be blank")
        end
      end

      context "when type is blank" do
        let(:type) { "" }

        it { is_expected.not_to be_valid }

        it "adds an error to the type field" do
          expect(errors[:details_things_taxed_type]).to include("Type cannot be blank")
        end
      end

      context "when rates are blank" do
        let(:rates) { "" }

        it { is_expected.not_to be_valid }

        it "adds an error to the rates field" do
          expect(errors[:details_things_taxed_rates]).to include("Rates cannot be blank")
        end
      end

      context "rate validation" do
        context "when name is blank" do
          let(:rate_name) { "" }

          it { is_expected.not_to be_valid }

          it "adds an error to the name field" do
            expect(errors[:details_things_taxed_rates_0_name]).to include("Name cannot be blank")
          end
        end

        context "when value is blank" do
          let(:rate_name) { "" }

          it { is_expected.not_to be_valid }

          it "adds an error to the name field" do
            expect(errors[:details_things_taxed_rates_0_name]).to include("Name cannot be blank")
          end
        end
      end

      context "band validation" do
        context "when name is blank" do
          let(:band_name) { "" }

          it { is_expected.not_to be_valid }

          it "adds an error to the name field" do
            expect(errors[:details_things_taxed_rates_0_bands_0_name]).to include("Name cannot be blank")
          end
        end
      end
    end
  end
end
