RSpec.describe Edition::Cloneable do
  before do
    allow(Organisation).to receive(:all).and_return([])
  end

  describe "#clone_edition" do
    it "clones an edition in draft with the specified creator" do
      edition = create(
        :edition, :pension,
        title: "Some title",
        details: { "my" => "details" },
        state: "published",
        change_note: "Something",
        internal_change_note: "Something else",
        lead_organisation_id: SecureRandom.uuid
      )
      creator = create(:user)

      new_edition = edition.clone_edition(creator:)

      expect("draft").to eq(new_edition.state)
      expect(new_edition.id).to be_nil
      expect(edition.lead_organisation_id).to eq(new_edition.lead_organisation_id)
      expect(creator).to eq(new_edition.creator)
      expect(edition.title).to eq(new_edition.title)
      expect(edition.details).to eq(new_edition.details)
      expect(new_edition.change_note).to be_nil
      expect(new_edition.internal_change_note).to be_nil
    end
  end

  describe "#clone_with_block" do
    let(:details) do
      {
        "section_one" => {
          "block1" => { "content" => "test content 1" },
          "block2" => { "content" => "test content 2" },
        },
        "section_two" => {
          "block3" => { "content" => "test content 3" },
        },
      }
    end

    let(:edition) { build(:edition, details:) }

    it "clones a specific block from the edition" do
      cloned = edition.clone_with_block("section_one.block1")

      expected_details = {
        "section_one" => {
          "block1" => { "content" => "test content 1" },
        },
      }
      expect(cloned.details).to eq(expected_details)
      expect(cloned.title).to be_nil
    end

    it "maintains original edition details" do
      edition.clone_with_block("section_one.block1")

      expect(edition.details).to eq(details)
    end

    it "returns empty details for non-existent block" do
      cloned = edition.clone_with_block("section_three.invalid_block")

      expect(cloned.details).to eq({ "section_three" => {} })
    end
  end

  describe "#clone_without_blocks" do
    let(:subschema) { double(id: "subschema") }
    let(:schema) { double(subschemas: [subschema]) }
    let(:document) { build(:document, schema:) }
    let(:details) { { "title" => "something", "subschema" => { "content" => "test content" } } }
    let(:edition) { build(:edition, details:, document:) }

    it "creates a copy without subschema blocks" do
      cloned = edition.clone_without_blocks

      expect(cloned.details).to eq({ "title" => "something" })
    end

    it "does not modify the original edition" do
      edition.clone_without_blocks

      expect(edition.details).to eq(details)
    end
  end
end
