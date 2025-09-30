require "test_helper"

class EditionTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:new_content_id) { SecureRandom.uuid }

  let(:created_at) { Time.zone.local(2000, 12, 31, 23, 59, 59).utc }
  let(:updated_at) { Time.zone.local(2000, 12, 31, 23, 59, 59).utc }
  let(:details) { { "some_field" => "some_content" } }
  let(:title) { "Edition title" }
  let(:creator) { create(:user) }
  let(:organisation) { build(:organisation) }
  let(:internal_change_note) { "My internal change note" }
  let(:change_note) { "My internal change note" }
  let(:major_change) { true }

  let(:edition) do
    Edition.new(
      created_at:,
      updated_at:,
      details:,
      document_attributes: {
        sluggable_string: "Something",
        block_type: "pension",
      },
      creator:,
      lead_organisation_id: organisation.id.to_s,
      title:,
      internal_change_note:,
      change_note:,
      major_change:,
    )
  end

  before do
    Edition.any_instance.stubs(:create_random_id).returns(new_content_id)
    edition.stubs(:schema).returns(build(:schema))
    Organisation.stubs(:all).returns([organisation])
  end

  it "exists with required data" do
    edition.save!
    edition.reload

    assert_equal created_at, edition.created_at
    assert_equal updated_at, edition.updated_at
    assert_equal details, edition.details
    assert_equal title, edition.title
    assert_equal internal_change_note, edition.internal_change_note
    assert_equal change_note, edition.change_note
    assert_equal major_change, edition.major_change
  end

  it "persists the block type to the document" do
    edition.save!
    edition.reload
    document = edition.document

    assert_equal document.block_type, edition.block_type
  end

  it "persists the content_id to the document" do
    edition.save!
    edition.reload
    document = edition.document

    assert_equal document.content_id, edition.content_id
  end

  it "creates a document" do
    edition.save!
    edition.reload

    assert_not_nil edition.document
    assert_equal new_content_id, edition.document.content_id
  end

  it "adds a content id if a document is provided" do
    edition.document = build(:document, :pension, content_id: nil)
    edition.save!
    edition.reload

    assert_not_nil edition.document
    assert_equal new_content_id, edition.document.content_id
  end

  it "validates the presence of a document block_type" do
    edition = build(
      :edition,
      created_at:,
      updated_at:,
      details:,
      document_attributes: {
        block_type: nil,
      },
      lead_organisation_id: organisation.id.to_s,
    )

    assert_invalid edition
    assert_includes edition.errors.messages[:"document.block_type"], I18n.t("activerecord.errors.models.document.attributes.block_type.blank")
  end

  it "validates the presence of an edition title" do
    edition = build(
      :edition,
      created_at:,
      updated_at:,
      details:,
      document_attributes: {},
      lead_organisation_id: organisation.id.to_s,
      title: nil,
    )

    assert_invalid edition
    assert edition.errors.full_messages.include?("Title cannot be blank")
  end

  describe "change note validation" do
    it "validates the presence of a change note if the change is major" do
      edition.change_note = nil
      edition.major_change = true

      assert_invalid edition, context: :change_note
      assert edition.errors.full_messages.include?("Change note cannot be blank")
    end

    it "is valid when the change is major and a change note is provided" do
      edition.change_note = "something"
      edition.major_change = true

      assert_valid edition, context: :change_note
    end

    it "validates the presence of the major_change boolean" do
      edition.major_change = nil

      assert_invalid edition, context: :change_note
      assert edition.errors.full_messages.include?("Select if users have to know the content has changed")
    end

    it "is valid when the change is minor and a change note is not provided" do
      edition.change_note = nil
      edition.major_change = false

      assert_valid edition, context: :change_note
    end
  end

  it "adds a creator and first edition author for new records" do
    edition.save!
    edition.reload
    assert_equal edition.creator, edition.edition_authors.first.user
  end

  describe "#creator_id=" do
    it "sets the creator given an ID" do
      user = create(:user)
      edition = build(:edition)
      edition.creator_id = user.id

      assert_equal edition.creator, user
    end
  end

  describe "#creator=" do
    it "raises an exception if called for a persisted record" do
      edition.save!
      assert_raise RuntimeError do
        edition.creator = create(:user)
      end
    end
  end

  describe "#update_document_reference_to_latest_edition!" do
    it "updates the document reference to the latest edition" do
      latest_edition = create(:edition, document: edition.document)
      latest_edition.update_document_reference_to_latest_edition!

      assert_equal latest_edition.document.latest_edition_id, latest_edition.id
    end
  end

  describe ".current_versions" do
    it "returns current published versions" do
      document = create(:document, :pension)
      edition = create(:edition, :pension, state: "published", document:)
      draft_edition = create(:edition, :pension, state: "draft", document:)
      document.latest_edition = draft_edition
      document.save!

      assert_equal Edition.current_versions.to_a, [edition]
    end
  end

  describe "#render" do
    let(:rendered_response) { "RENDERED" }
    let(:stub_block) { stub("ContentBlockTools::ContentBlock", render: rendered_response) }
    let(:document) { edition.document }
    let(:embed_code) { "embed_code" }

    it "initializes and renders a content block" do
      ContentBlockTools::ContentBlock.expects(:new)
                                     .with(
                                       document_type: "content_block_#{document.block_type}",
                                       content_id: document.content_id,
                                       title:,
                                       details:,
                                       embed_code:,
                                     ).returns(stub_block)

      assert_equal edition.render(embed_code), rendered_response
    end

    it "uses the document's embed code as default if none is provided" do
      ContentBlockTools::ContentBlock.expects(:new)
                                     .with(
                                       document_type: "content_block_#{document.block_type}",
                                       content_id: document.content_id,
                                       title:,
                                       details:,
                                       embed_code: document.embed_code,
                                     ).returns(stub_block)

      assert_equal edition.render, rendered_response
    end
  end

  describe "#add_object_to_details" do
    it "adds an object with the correct key to the details hash" do
      edition.add_object_to_details("something", { "title" => "My thing", "something" => "else" })

      assert_equal edition.details["something"], { "my-thing" => { "title" => "My thing", "something" => "else" } }
    end

    it "appends to the object if it already exists" do
      edition.details["something"] = {
        "another-thing" => {},
      }

      edition.add_object_to_details("something", { "title" => "My thing", "something" => "else" })
      assert_equal edition.details["something"], { "another-thing" => {}, "my-thing" => { "title" => "My thing", "something" => "else" } }
    end

    describe "when an object with the same title already exists" do
      before do
        edition.details["something"] = {
          "my-thing" => {
            "title" => "My thing",
            "something" => "here",
          },
        }
      end

      it "generates a new key" do
        edition.add_object_to_details("something", { "title" => "My thing", "something" => "else" })
        assert_equal edition.details["something"], {
          "my-thing" => {
            "title" => "My thing",
            "something" => "here",
          },
          "my-thing-1" => {
            "title" => "My thing",
            "something" => "else",
          },
        }
      end

      it "tries again if there is already an exising key" do
        10.times do |i|
          edition.details["something"]["my-thing-#{i}"] = {
            "title" => "My thing",
            "something" => "here",
          }
        end

        edition.add_object_to_details("something", { "title" => "My thing", "something" => "else" })

        expected = edition.details["something"].merge({ "my-thing-10" => { "title" => "My thing", "something" => "else" } })
        assert_equal edition.details["something"], expected
      end
    end

    describe "when a title is not provided" do
      it "creates a key using the object type" do
        edition.add_object_to_details("something", { "something" => "else" })
        edition.add_object_to_details("something", { "something" => "additional" })

        assert_equal edition.details["something"], {
          "something" => { "something" => "else" },
          "something-1" => { "something" => "additional" },
        }
      end
    end

    describe "when a title is blank" do
      it "creates a key using the object type" do
        edition.add_object_to_details("something", { "title" => "", "something" => "else" })
        edition.add_object_to_details("something", { "title" => "", "something" => "additional" })

        assert_equal edition.details["something"], {
          "something" => { "title" => "", "something" => "else" },
          "something-1" => { "title" => "", "something" => "additional" },
        }
      end
    end

    it "removes deleted items from the array, as well as the `_destroy` markers" do
      edition.add_object_to_details("something", {
        "title" => "A title",
        "array_items" => [
          { "name" => "item 1", "_destroy" => "0" },
          { "name" => "item 2", "_destroy" => "1" },
          { "name" => "item 3", "_destroy" => "0" },
        ],
      })

      assert_equal edition.details["something"], {
        "a-title" => {
          "title" => "A title",
          "array_items" => [
            { "name" => "item 1" },
            { "name" => "item 3" },
          ],
        },
      }
    end
  end

  describe "#update_object_with_details" do
    before do
      edition.details["something"] = { "my-thing" => { "title" => "My thing", "something" => "else", "boolean" => true } }
    end

    it "updates a given object's details" do
      edition.update_object_with_details("something", "my-thing", { "title" => "My thing", "something" => "changed", "boolean" => true })

      assert_equal edition.details["something"], { "my-thing" => { "title" => "My thing", "something" => "changed", "boolean" => true } }
    end

    it "keeps the original key if the title changes" do
      edition.update_object_with_details("something", "my-thing", { "title" => "Other thing", "something" => "changed", "boolean" => true })

      assert_equal edition.details["something"], { "my-thing" => { "title" => "Other thing", "something" => "changed", "boolean" => true } }
    end

    describe "when an object has an array" do
      before do
        edition.details["something"] = {
          "my-thing" => {
            "title" => "My thing",
            "array_items" => [
              { "name" => "item 1" },
              { "name" => "item 2" },
              { "name" => "item 3" },
            ],
          },
        }
      end

      it "removes deleted items from the array, as well as the `_destroy` markers" do
        edition.update_object_with_details("something", "my-thing", {
          "title" => "My thing",
          "array_items" => [
            { "name" => "item 1", "_destroy" => "0" },
            { "name" => "item 2", "_destroy" => "1" },
            { "name" => "item 3", "_destroy" => "0" },
          ],
        })

        assert_equal edition.details["something"], {
          "my-thing" => {
            "title" => "My thing",
            "array_items" => [
              { "name" => "item 1" },
              { "name" => "item 3" },
            ],
          },
        }
      end
    end
  end

  describe "#clone_edition" do
    it "clones an edition in draft with the specified creator" do
      edition = create(
        :edition, :pension,
        title: "Some title",
        details: { "my" => "details" },
        state: "published",
        change_note: "Something",
        internal_change_note: "Something else"
      )
      creator = create(:user)

      new_edition = edition.clone_edition(creator:)

      assert_equal new_edition.state, "draft"
      assert_nil new_edition.id
      assert_equal new_edition.lead_organisation, edition.lead_organisation
      assert_equal new_edition.creator, creator
      assert_equal new_edition.title, edition.title
      assert_equal new_edition.details, edition.details
      assert_nil new_edition.change_note
      assert_nil new_edition.internal_change_note
    end
  end

  describe "#has_entries_for_subschema_id?" do
    it "returns false when there are no entries for a subschema ID" do
      edition.details["foo"] = {}

      assert_not edition.has_entries_for_subschema_id?("foo")
    end

    it "returns true when there entries for a subschema ID" do
      edition.details["foo"] = { "something" => { "foo" => "bar" } }

      assert edition.has_entries_for_subschema_id?("foo")
    end
  end
end
