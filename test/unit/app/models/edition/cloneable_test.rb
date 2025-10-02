require "test_helper"

class Edition::CloneableTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  before do
    Organisation.stubs(:all).returns([])
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

      assert_equal new_edition.state, "draft"
      assert_nil new_edition.id
      assert_equal new_edition.lead_organisation_id, edition.lead_organisation_id
      assert_equal new_edition.creator, creator
      assert_equal new_edition.title, edition.title
      assert_equal new_edition.details, edition.details
      assert_nil new_edition.change_note
      assert_nil new_edition.internal_change_note
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
      assert_equal expected_details, cloned.details
      assert_nil cloned.title
    end

    it "maintains original edition details" do
      edition.clone_with_block("section_one.block1")

      assert_equal details, edition.details
    end

    it "returns empty details for non-existent block" do
      cloned = edition.clone_with_block("section_three.invalid_block")

      assert_equal({ "section_three" => {} }, cloned.details)
    end
  end

  describe "#clone_without_blocks" do
    let(:subschema) { stub(id: "subschema") }
    let(:schema) { stub(subschemas: [subschema]) }
    let(:document) { build(:document, schema:) }
    let(:details) { { "title" => "something", "subschema" => { "content" => "test content" } } }
    let(:edition) { build(:edition, details:, document:) }

    it "creates a copy without subschema blocks" do
      cloned = edition.clone_without_blocks

      assert_equal({ "title" => "something" }, cloned.details)
    end

    it "does not modify the original edition" do
      edition.clone_without_blocks

      assert_equal details, edition.details
    end
  end
end
