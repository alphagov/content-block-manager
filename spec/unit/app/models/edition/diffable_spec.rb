RSpec.describe Edition::Diffable do
  let(:document) { create(:document, :pension) }

  let(:organisation) { build(:organisation) }
  let(:previous_edition) do
    create(:edition, document:, created_at: Time.zone.now - 2.days, lead_organisation_id: organisation.id)
  end
  let(:edition) do
    create(:edition, document:, lead_organisation_id: organisation.id)
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

      it "returns a details diff if any items in the details have changed" do
        previous_edition.details = { "email_address": "old@example.com" }
        previous_edition.save!

        edition.details = { "email_address": "new@example.com" }
        edition.save!

        expected_diff = {
          "details" => {
            "email_address" => DiffItem.new(
              previous_value: "old@example.com",
              new_value: "new@example.com",
            ),
          },
        }

        expect(expected_diff).to eq(edition.generate_diff)
      end

      it "returns a nested details diff for any changes to nested objects" do
        previous_edition.details = {
          "rates" => {
            "rate-1" => {
              "amount" => "£124.55",
            },
            "other-rate" => {
              "amount" => "£5",
            },
          },
        }
        previous_edition.save!

        edition.details = {
          "rates" => {
            "rate-1" => {
              "amount" => "£124.22",
            },
            "rate-2" => {
              "amount" => "£99.50",
            },
          },
        }
        edition.save!

        expected_diffs = {
          "details" => {
            "rates" => {
              "rate-1" => {
                "amount" => DiffItem.new(
                  previous_value: "£124.55",
                  new_value: "£124.22",
                ),
              },
              "other-rate" => {
                "amount" => DiffItem.new(
                  previous_value: "£5",
                  new_value: nil,
                ),
              },
              "rate-2" => {
                "amount" => DiffItem.new(
                  previous_value: nil,
                  new_value: "£99.50",
                ),
              },
            },
          },
        }

        expect(expected_diffs).to eq(edition.generate_diff)
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
