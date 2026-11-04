RSpec.describe V2::Edition::Diffable do
  let(:document) { create(:v2_document) }

  let(:organisation) { build(:organisation) }
  let!(:previous_edition) do
    create(:v2_time_period_edition, document:, created_at: Time.zone.now - 2.days, lead_organisation_id: organisation.id, title: "Something")
  end
  let!(:edition) do
    create(:v2_time_period_edition, document:, lead_organisation_id: organisation.id, title: "Something")
  end

  before do
    allow(Organisation).to receive(:all).and_return([organisation])
  end

  describe "#generate_diff" do
    describe "when the document is a new block" do
      before do
        expect(edition.document).to receive(:is_new_block?).and_return(true)
      end

      it "returns an empty hash" do
        expect({}).to eq(edition.generate_diff)
      end
    end

    describe "when the document is not a new block" do
      before do
        expect(edition.document).to receive(:is_new_block?).and_return(false)
      end

      it "returns a diff if the title has changed" do
        previous_edition.title = "Something old"
        previous_edition.save!

        edition.title = "Something new"
        edition.save!

        expected_diff = {
          "title" => DiffItem.new(
            previous_value: "Something old",
            new_value: "Something new",
          ),
        }

        expect(expected_diff).to eq(edition.generate_diff)
      end

      it "returns a diff if the organisation has changed" do
        old_organisation = build(:organisation, name: "One Organisation")
        new_organisation = build(:organisation, name: "Another Organisation")

        allow(Organisation).to receive(:all).and_return([old_organisation, new_organisation])

        previous_edition.lead_organisation_id = old_organisation.id
        previous_edition.save!

        edition.lead_organisation_id = new_organisation.id
        edition.save!

        expected_diff = {
          "lead_organisation" => DiffItem.new(
            previous_value: "One Organisation",
            new_value: "Another Organisation",
          ),
        }

        expect(expected_diff).to eq(edition.generate_diff)
      end

      it "returns a diff if instructions_to_publishers has changed" do
        previous_edition.instructions_to_publishers = "Old instructions"
        previous_edition.save!

        edition.instructions_to_publishers = "New instructions"
        edition.save!

        expected_diff = {
          "instructions_to_publishers" => DiffItem.new(
            previous_value: "Old instructions",
            new_value: "New instructions",
          ),
        }

        expect(expected_diff).to eq(edition.generate_diff)
      end
    end
  end
end
