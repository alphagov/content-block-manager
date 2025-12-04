RSpec.describe Edition, type: :model do
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
    allow_any_instance_of(Edition).to receive(:create_random_id).and_return(new_content_id)
    allow(edition).to receive(:schema).and_return(build(:schema))
    allow(Organisation).to receive(:all).and_return([organisation])
  end

  it "exists with required data" do
    edition.save!
    edition.reload

    aggregate_failures do
      expect(edition.created_at).to eq(created_at)
      expect(edition.updated_at).to eq(updated_at)
      expect(edition.details).to eq(details)
      expect(edition.title).to eq(title)
      expect(edition.internal_change_note).to eq(internal_change_note)
      expect(edition.change_note).to eq(change_note)
      expect(edition.major_change).to eq(major_change)
    end
  end

  it "persists the block type to the document" do
    edition.save!
    edition.reload
    document = edition.document

    expect(edition.block_type).to eq(document.block_type)
  end

  it "persists the content_id to the document" do
    edition.save!
    edition.reload
    document = edition.document

    expect(edition.content_id).to eq(document.content_id)
  end

  it "sets the #embed_code to the document using the 'friendly' form of #sluggable_string" do
    edition.document[:sluggable_string] = "My block name"

    edition.save!
    edition.reload
    edition.document

    expect(edition.document.embed_code).to eq(
      "{{embed:content_block_pension:my-block-name}}",
    )
  end

  it "creates a document" do
    edition.save!
    edition.reload

    aggregate_failures do
      expect(edition.document).not_to be_nil
      expect(edition.document.content_id).to eq(new_content_id)
    end
  end

  it "adds a content id if a document is provided" do
    edition.document = build(:document, :pension, content_id: nil)
    edition.save!
    edition.reload

    aggregate_failures do
      expect(edition.document).not_to be_nil
      expect(edition.document.content_id).to eq(new_content_id)
    end
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

    aggregate_failures do
      expect_model_not_to_be_valid(model: edition)
      expect(edition.errors.messages[:"document.block_type"]).to include("Select a content block")
    end
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

    aggregate_failures do
      expect_model_not_to_be_valid(model: edition)
      expect(edition.errors.full_messages).to include("Title cannot be blank")
    end
  end

  describe "change note validation" do
    it "validates the presence of a change note if the change is major" do
      edition.change_note = nil
      edition.major_change = true

      aggregate_failures do
        expect_model_not_to_be_valid(model: edition, context: :change_note)
        expect(edition.errors.full_messages).to include("Change note cannot be blank")
      end
    end

    it "is valid when the change is major and a change note is provided" do
      edition.change_note = "something"
      edition.major_change = true

      expect_model_to_be_valid(model: edition, context: :change_note)
    end

    it "validates the presence of the major_change boolean" do
      edition.major_change = nil

      aggregate_failures do
        expect_model_not_to_be_valid(model: edition, context: :change_note)
        expect(edition.errors.full_messages).to include("Select if users have to know the content has changed")
      end
    end

    it "is valid when the change is minor and a change note is not provided" do
      edition.change_note = nil
      edition.major_change = false

      expect_model_to_be_valid(model: edition, context: :change_note)
    end
  end

  it "adds a creator and first edition author for new records" do
    edition.save!
    edition.reload

    expect(edition.edition_authors.last.user).to eq(edition.creator)
  end

  describe "#creator_id=" do
    it "sets the creator given an ID" do
      user = create(:user)
      edition = build(:edition)
      edition.creator_id = user.id

      expect(user).to eq(edition.creator)
    end
  end

  describe "#creator=" do
    it "raises an exception if called for a persisted record" do
      edition.save!

      expect {
        edition.creator = create(:user)
      }.to raise_error(RuntimeError)
    end
  end

  describe ".current_versions" do
    it "returns current published versions" do
      document = create(:document, :pension)
      published_edition = create(:edition, :pension, :published, document: document)
      additional_published_edition = create(:edition, :pension, :published, document: document)
      draft_edition = create(:edition, :pension, :draft, document: document)

      aggregate_failures do
        expect(Edition.current_versions.to_a).to include(additional_published_edition)
        expect(Edition.current_versions.to_a).to include(published_edition)
        expect(Edition.current_versions.to_a).not_to include(draft_edition)
      end
    end
  end

  describe "#render" do
    let(:rendered_response) { "RENDERED" }
    let(:stub_block) { double("ContentBlockTools::ContentBlock", render: rendered_response) }
    let(:document) { edition.document }
    let(:embed_code) { "embed_code" }

    it "initializes and renders a content block" do
      expect(ContentBlockTools::ContentBlock).to receive(:new)
        .with(
          document_type: "content_block_#{document.block_type}",
          content_id: document.content_id,
          title:,
          details:,
          embed_code:,
        ).and_return(stub_block)

      expect(edition.render(embed_code)).to eq(rendered_response)
    end

    it "uses the document's embed code as default if none is provided" do
      expect(ContentBlockTools::ContentBlock).to receive(:new)
        .with(
          document_type: "content_block_#{document.block_type}",
          content_id: document.content_id,
          title:,
          details:,
          embed_code: document.embed_code,
        ).and_return(stub_block)

      expect(edition.render).to eq(rendered_response)
    end
  end

  describe "#add_object_to_details" do
    it "adds an object with the correct key to the details hash" do
      edition.add_object_to_details(
        "something",
        { "title" => "My thing", "something" => "else" },
      )

      expect(edition.details["something"]).to eq(
        {
          "my-thing" => {
            "title" => "My thing",
            "something" => "else",
          },
        },
      )
    end

    it "appends to the object if it already exists" do
      edition.details["something"] = {
        "another-thing" => {},
      }

      edition.add_object_to_details(
        "something",
        { "title" => "My thing", "something" => "else" },
      )

      expect(edition.details["something"]).to eq(
        {
          "another-thing" => {},
          "my-thing" => { "title" => "My thing", "something" => "else" },
        },
      )
    end

    context "when an object with the same title already exists" do
      before do
        edition.details["something"] = {
          "my-thing" => {
            "title" => "My thing",
            "something" => "here",
          },
        }
      end

      it "generates a new key" do
        edition.add_object_to_details(
          "something",
          { "title" => "My thing", "something" => "else" },
        )

        expect(edition.details["something"]).to eq(
          {
            "my-thing" => {
              "title" => "My thing",
              "something" => "here",
            },
            "my-thing-1" => {
              "title" => "My thing",
              "something" => "else",
            },
          },
        )
      end

      it "tries again if there is already an existing key" do
        10.times do |i|
          edition.details["something"]["my-thing-#{i}"] = {
            "title" => "My thing",
            "something" => "here",
          }
        end

        edition.add_object_to_details(
          "something",
          { "title" => "My thing", "something" => "else" },
        )

        expected = edition.details["something"].merge(
          { "my-thing-10" => { "title" => "My thing", "something" => "else" } },
        )
        expect(edition.details["something"]).to eq(expected)
      end
    end

    context "when a title is not provided" do
      it "creates a key using the object type" do
        edition.add_object_to_details("something", { "something" => "else" })
        edition.add_object_to_details("something", { "something" => "additional" })

        expect(edition.details["something"]).to eq(
          {
            "something" => { "something" => "else" },
            "something-1" => { "something" => "additional" },
          },
        )
      end
    end

    context "when a title is blank" do
      it "creates a key using the object type" do
        edition.add_object_to_details("something", { "title" => "", "something" => "else" })
        edition.add_object_to_details("something", { "title" => "", "something" => "additional" })

        expect(edition.details["something"]).to eq(
          {
            "something" => { "title" => "", "something" => "else" },
            "something-1" => { "title" => "", "something" => "additional" },
          },
        )
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

      expect(edition.details["something"]).to eq(
        {
          "a-title" => {
            "title" => "A title",
            "array_items" => [
              { "name" => "item 1" },
              { "name" => "item 3" },
            ],
          },
        },
      )
    end
  end

  describe "#update_object_with_details" do
    before do
      edition.details["something"] = {
        "my-thing" => { "title" => "My thing", "something" => "else", "boolean" => true },
      }
    end

    it "updates a given object's details" do
      edition.update_object_with_details(
        "something", "my-thing",
        { "title" => "My thing", "something" => "changed", "boolean" => true }
      )

      expect(edition.details["something"]).to eq(
        {
          "my-thing" => { "title" => "My thing", "something" => "changed", "boolean" => true },
        },
      )
    end

    it "keeps the original key if the title changes" do
      edition.update_object_with_details(
        "something", "my-thing",
        { "title" => "Other thing", "something" => "changed", "boolean" => true }
      )

      expect(edition.details["something"]).to eq(
        {
          "my-thing" => { "title" => "Other thing", "something" => "changed", "boolean" => true },
        },
      )
    end

    context "when an object has an array" do
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

        expect(edition.details["something"]).to eq(
          {
            "my-thing" => {
              "title" => "My thing",
              "array_items" => [
                { "name" => "item 1" },
                { "name" => "item 3" },
              ],
            },
          },
        )
      end
    end
  end

  describe "#has_entries_for_subschema_id?" do
    it "returns false when there are no entries for a subschema ID" do
      edition.details["foo"] = {}

      expect(edition.has_entries_for_subschema_id?("foo")).to be false
    end

    it "returns true when there entries for a subschema ID" do
      edition.details["foo"] = { "something" => { "foo" => "bar" } }

      expect(edition.has_entries_for_subschema_id?("foo")).to be true
    end
  end

  describe "#has_entries_for_multiple_subschemas?" do
    let(:subschemas) { [double(:subschema, id: "foo"), double(:subschema, id: "bar")] }
    let(:schema) { double(:schema, subschemas: subschemas) }
    let(:document) { build(:document, schema: schema) }
    let(:edition) { build(:edition, document: document) }

    it "returns true when an edition has entries for multiple subschemas" do
      allow(edition).to receive(:has_entries_for_subschema_id?).with(subschemas[0].id).and_return(true)
      allow(edition).to receive(:has_entries_for_subschema_id?).with(subschemas[1].id).and_return(true)

      expect(edition.has_entries_for_multiple_subschemas?).to be true
    end

    it "returns false when an edition has entries for one subschema" do
      allow(edition).to receive(:has_entries_for_subschema_id?).with(subschemas[0].id).and_return(false)
      allow(edition).to receive(:has_entries_for_subschema_id?).with(subschemas[1].id).and_return(true)

      expect(edition.has_entries_for_multiple_subschemas?).to be false
    end

    it "returns false when an edition has entries for no subschemas" do
      allow(edition).to receive(:has_entries_for_subschema_id?).and_return(false)

      expect(edition.has_entries_for_multiple_subschemas?).to be false
    end
  end

  describe "#default_order" do
    let(:details) do
      {
        "telephones" => {
          "telephone_1" => {
            "something" => "here",
          },
        },
        "addresses" => {
          "address_1" => {
            "something" => "here",
          },
        },
        "email_addresses" => {
          "email_address_1" => {
            "something" => "here",
          },
          "email_address_2" => {
            "something" => "here",
          },
        },
        "contact_links" => {
          "contact_link_1" => {
            "something" => "here",
          },
        },
      }
    end
    let(:edition) { create(:edition, document:, details:) }
    let(:subschemas) do
      [
        double(:subschema, id: "email_addresses", block_type: "email_addresses", group_order: 1),
        double(:subschema, id: "telephones", block_type: "telephones", group_order: 4),
        double(:subschema, id: "addresses", block_type: "addresses", group_order: 2),
        double(:subschema, id: "contact_links", block_type: "contact_links", group_order: 3),
      ]
    end
    let(:schema) { double(:schema, subschemas: subschemas, body: {}) }
    let(:document) { build(:document, schema:) }

    before do
      allow(document).to receive(:schema).and_return(schema)
    end

    it "returns the default order" do
      expect(edition.default_order).to eq(
        %w[
          email_addresses.email_address_1
          email_addresses.email_address_2
          addresses.address_1
          contact_links.contact_link_1
          telephones.telephone_1
        ],
      )
    end
  end

  describe "#is_scheduling?" do
    it "should return true if the edition is being scheduled" do
      edition.scheduled_publication = Time.zone.now
      expect(edition.is_scheduling?).to be true
    end

    it "should return false if the edition is not being scheduled" do
      edition.scheduled_publication = nil
      expect(edition.is_scheduling?).to be false
    end
  end

  describe "#completed?" do
    context "when #workflow_completed_at is nil" do
      before { edition.workflow_completed_at = nil }

      it "returns false" do
        expect(edition.completed?).to be false
      end
    end

    context "when #workflow_completed_at is set" do
      before { edition.workflow_completed_at = 1.hour.ago }

      it "returns false" do
        expect(edition.completed?).to be true
      end
    end
  end

  describe "#is_deletable?" do
    it "should return true if the edition is not published" do
      Edition.in_progress_states.each do |state|
        edition.state = state
        expect(edition.is_deletable?).to be true
      end
    end

    it "should return false if the edition is finalised" do
      Edition.finalised_states.each do |state|
        edition.state = state
        expect(edition.is_deletable?).to be false
      end
    end
  end
end
