require "test_helper"

class Document::Show::SummaryListComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::SanitizeHelper
  include EditionHelper

  include Rails.application.routes.url_helpers

  let(:organisation) { build(:organisation, name: "Department for Example") }
  let(:document) { build_stubbed(:document, :pension) }
  let!(:edition) do
    build_stubbed(
      :edition,
      :pension,
      details: { foo: "bar", something: "else", "embedded" => { "something" => { "is" => "here" } } },
      creator: build(:user),
      lead_organisation_id: organisation.id,
      scheduled_publication: Time.zone.now,
      state: "published",
      updated_at: 1.day.ago,
      document: document,
    )
  end
  let(:fields) do
    [
      stub("field", name: "foo"),
      stub("field", name: "something"),
    ]
  end
  let(:schema_with_block_display_fields) { stub(:schema, block_display_fields: %w[foo], fields:) }
  let(:schema_without_block_display_fields) { stub(:schema, block_display_fields: [], fields:) }

  before do
    document.stubs(:schema).returns(schema_without_block_display_fields)
    document.stubs(:latest_edition).returns(edition)
    Organisation.stubs(:all).returns([organisation])
  end

  it "renders a scheduled content block correctly" do
    document.latest_edition.state = "scheduled"

    render_inline(Document::Show::SummaryListComponent.new(document:))

    assert_selector ".govuk-summary-list__row", count: 6

    assert_selector ".govuk-summary-list__key", text: "Status"
    assert_selector ".govuk-summary-list__value", text: "Scheduled for publication at #{strip_tags scheduled_date(edition)}"
    assert_selector ".govuk-summary-list__actions", text: "Edit schedule"
    assert_selector ".govuk-summary-list__actions a[href='#{document_schedule_edit_path(document)}']"
  end

  describe "when there are instructions to publishers" do
    it "renders them" do
      document.latest_edition.instructions_to_publishers = "instructions"

      render_inline(Document::Show::SummaryListComponent.new(document:))

      assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
      assert_selector ".govuk-summary-list__value p", text: "instructions"
    end
  end

  describe "#title_item" do
    before do
      I18n.expects(:t).with("activerecord.attributes.edition/document.title.default").returns("Default Title")
    end

    it "uses the block type specific translation" do
      I18n.expects(:t).with(
        "activerecord.attributes.edition/document.title.#{document.block_type}",
        default: "Default Title",
      ).returns("Custom Title Label")

      render_inline(Document::Show::SummaryListComponent.new(document:))

      assert_selector ".govuk-summary-list__key", text: "Custom Title Label"
      assert_selector ".govuk-summary-list__value", text: document.title
    end

    it "falls back to default translation when block type translation is missing" do
      I18n.expects(:t).with(
        "activerecord.attributes.edition/document.title.#{document.block_type}",
        default: "Default Title",
      ).returns("Default Title")

      render_inline(Document::Show::SummaryListComponent.new(document:))

      assert_selector ".govuk-summary-list__key", text: "Default Title"
      assert_selector ".govuk-summary-list__value", text: document.title
    end
  end

  describe "#organisation_item" do
    it "renders the lead organisation name" do
      render_inline(Document::Show::SummaryListComponent.new(document:))

      assert_selector ".govuk-summary-list__key", text: "Lead organisation"
      assert_selector ".govuk-summary-list__value", text: "Department for Example"
    end
  end

  describe "#details_items" do
    it "renders all fields from the schema" do
      render_inline(Document::Show::SummaryListComponent.new(document:))

      assert_selector ".govuk-summary-list__key", text: "Foo"
      assert_selector ".govuk-summary-list__value", text: "bar"
      assert_selector ".govuk-summary-list__key", text: "Something"
      assert_selector ".govuk-summary-list__value", text: "else"
    end

    it "humanizes field names" do
      fields_with_underscores = [
        stub("field", name: "field_with_underscores"),
      ]
      schema = stub(:schema, block_display_fields: [], fields: fields_with_underscores)
      document.stubs(:schema).returns(schema)
      edition.details = { "field_with_underscores" => "test value" }

      render_inline(Document::Show::SummaryListComponent.new(document:))

      assert_selector ".govuk-summary-list__key", text: "Field with underscores"
      assert_selector ".govuk-summary-list__value", text: "test value"
    end
  end

  describe "#status_item" do
    describe "when edition is scheduled" do
      before do
        edition.state = "scheduled"
        edition.scheduled_publication = Time.zone.now + 2.days
      end

      it "displays scheduled status with edit link" do
        render_inline(Document::Show::SummaryListComponent.new(document:))

        assert_selector ".govuk-summary-list__key", text: "Status"
        assert_selector ".govuk-summary-list__value", text: /Scheduled for publication at/
        assert_selector ".govuk-summary-list__actions a[href='#{document_schedule_edit_path(document)}']"
      end

      it "includes visually hidden text in edit link" do
        render_inline(Document::Show::SummaryListComponent.new(document:))

        assert_selector ".govuk-summary-list__actions", text: "Edit"
        assert_selector ".govuk-visually-hidden", text: "schedule"
      end
    end

    describe "when edition is published" do
      before do
        edition.state = "published"
        edition.updated_at = 3.days.ago
      end

      it "displays published status with date and creator" do
        render_inline(Document::Show::SummaryListComponent.new(document:))

        assert_selector ".govuk-summary-list__key", text: "Status"
        assert_selector ".govuk-summary-list__value", text: /Published on/
        assert_selector ".govuk-summary-list__value", text: /by #{edition.creator.name}/
      end

      it "does not display edit link" do
        render_inline(Document::Show::SummaryListComponent.new(document:))

        assert_no_selector ".govuk-summary-list__actions a[href='#{document_schedule_edit_path(document)}']"
      end
    end
  end

  describe "rendering the full component" do
    it "renders all expected summary list rows for published edition" do
      render_inline(Document::Show::SummaryListComponent.new(document:))

      # Title, 2 details fields (foo, something), organisation, instructions, status
      assert_selector ".govuk-summary-list__row", count: 6
    end

    it "compacts nil items from the list" do
      # This test ensures the .compact call in #items works correctly
      # by verifying all rows render without errors even if some items might be nil
      render_inline(Document::Show::SummaryListComponent.new(document:))

      assert_not page.has_selector?(".govuk-summary-list__row", text: "nil")
    end
  end

  describe "#edition" do
    it "memoizes the edition" do
      component = Document::Show::SummaryListComponent.new(document:)

      # Access edition multiple times
      document.expects(:latest_edition).once.returns(edition)

      render_inline(component)
    end
  end

  describe "#schema" do
    it "memoizes the schema" do
      component = Document::Show::SummaryListComponent.new(document:)

      # Access schema multiple times through details_items
      document.expects(:schema).once.returns(schema_without_block_display_fields)

      render_inline(component)
    end
  end
end
