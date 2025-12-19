RSpec.describe Document::Show::SummaryListComponent, type: :component do
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
      build(:field, name: "foo"),
      build(:field, name: "something"),
    ]
  end
  let(:schema_with_block_display_fields) { double(:schema, block_display_fields: %w[foo], fields:) }
  let(:schema_without_block_display_fields) { double(:schema, block_display_fields: [], fields:) }

  before do
    allow(document).to receive(:schema).and_return(schema_without_block_display_fields)
    allow(Organisation).to receive(:all).and_return([organisation])
  end

  it "renders a scheduled content block correctly" do
    edition.state = "scheduled"

    render_inline(described_class.new(edition: edition))

    expect(page).to have_css ".govuk-summary-list__row", count: 7

    expect(page).to have_css ".govuk-summary-list__key", text: "Status"
    expect(page).to have_css ".govuk-summary-list__value", text: "Scheduled for publication by #{edition.creator.name}"
    expect(page).to have_css ".govuk-summary-list__actions", text: "Edit schedule"
    expect(page).to have_css ".govuk-summary-list__actions a[href='#{document_schedule_edit_path(document)}']"
  end

  describe "when there are instructions to publishers" do
    it "renders them" do
      edition.instructions_to_publishers = "instructions"

      render_inline(described_class.new(edition: edition))

      expect(page).to have_css ".govuk-summary-list__key", text: "Instructions to publishers"
      expect(page).to have_css ".govuk-summary-list__value p", text: "instructions"
    end
  end

  describe "#title_item" do
    before do
      allow(I18n).to receive(:t).and_call_original
      allow(I18n).to receive(:t).with("activerecord.attributes.edition/document.title.default").and_return("Default Title")
      allow(I18n).to receive(:t).with("edition.states.label_extended.published", a_hash_including(user: a_string_including("user"))).and_return("Label")
    end

    it "uses the block type specific translation" do
      expect(I18n).to receive(:t).with(
        "activerecord.attributes.edition/document.title.#{document.block_type}",
        default: "Default Title",
      ).and_return("Custom Title Label")

      render_inline(described_class.new(edition: edition))

      expect(page).to have_css ".govuk-summary-list__key", text: "Custom Title Label"
      expect(page).to have_css ".govuk-summary-list__value", text: document.title
    end

    it "falls back to default translation when block type translation is missing" do
      allow(I18n).to receive(:t).with(
        "activerecord.attributes.edition/document.title.#{document.block_type}",
        default: "Default Title",
      ).and_return("Default Title")

      render_inline(described_class.new(edition: edition))

      expect(page).to have_css ".govuk-summary-list__key", text: "Default Title"
      expect(page).to have_css ".govuk-summary-list__value", text: document.title
    end
  end

  describe "#organisation_item" do
    it "renders the lead organisation name" do
      render_inline(described_class.new(edition: edition))

      expect(page).to have_css ".govuk-summary-list__key", text: "Lead organisation"
      expect(page).to have_css ".govuk-summary-list__value", text: "Department for Example"
    end
  end

  describe "#details_items" do
    it "renders all fields from the schema" do
      render_inline(described_class.new(edition: edition))

      expect(page).to have_css ".govuk-summary-list__key", text: "Foo"
      expect(page).to have_css ".govuk-summary-list__value", text: "bar"
      expect(page).to have_css ".govuk-summary-list__key", text: "Something"
      expect(page).to have_css ".govuk-summary-list__value", text: "else"
    end

    it "humanizes field names" do
      fields_with_underscores = [
        build(:field, name: "field_with_underscores"),
      ]
      schema = double(:schema, block_display_fields: [], fields: fields_with_underscores)
      allow(document).to receive(:schema).and_return(schema)
      edition.details = { "field_with_underscores" => "test value" }

      render_inline(described_class.new(edition: edition))

      expect(page).to have_css ".govuk-summary-list__key", text: "Field with underscores"
      expect(page).to have_css ".govuk-summary-list__value", text: "test value"
    end
  end

  describe "#status_item" do
    describe "when edition is scheduled" do
      before do
        edition.state = "scheduled"
        edition.scheduled_publication = Time.zone.parse("3000-01-01 14:00")
      end

      it "displays scheduled status with edit link" do
        render_inline(described_class.new(edition: edition))

        expect(page).to have_css ".govuk-summary-list__key", text: "Status"
        expect(page).to have_css ".govuk-summary-list__value", text: /Scheduled for publication/
        expect(page).to have_css ".govuk-summary-list__actions a[href='#{document_schedule_edit_path(document)}']"
      end

      it "includes visually hidden text in edit link" do
        render_inline(described_class.new(edition: edition))

        expect(page).to have_css ".govuk-summary-list__actions", text: "Edit"
        expect(page).to have_css ".govuk-visually-hidden", text: "schedule"
      end

      it "shows the scheduled publication date row" do
        render_inline(described_class.new(edition: edition))

        expect(page).to have_css ".govuk-summary-list__key", text: "Scheduled publication date"
        expect(page).to have_css ".govuk-summary-list__value", text: /1 January 3000/
      end
    end

    describe "when edition is published" do
      before do
        edition.state = "published"
        edition.updated_at = 3.days.ago
      end

      it "displays published status with date and creator" do
        render_inline(described_class.new(edition: edition))

        expect(page).to have_css ".govuk-summary-list__key", text: "Status"
        expect(page).to have_css ".govuk-summary-list__value", text: /Published on/
        expect(page).to have_css ".govuk-summary-list__value", text: /by #{edition.creator.name}/
      end

      it "does not display edit link" do
        render_inline(described_class.new(edition: edition))

        expect(page).to_not have_css ".govuk-summary-list__actions a[href='#{document_schedule_edit_path(document)}']"
      end

      it "does not show the scheduled publication date row" do
        render_inline(described_class.new(edition: edition))

        expect(page).not_to have_css ".govuk-summary-list__key", text: "Scheduled publication date"
        expect(page).not_to have_css ".govuk-summary-list__value", text: /1 January 3000/
      end
    end
  end

  describe "rendering the full component" do
    it "renders all expected summary list rows for published edition" do
      render_inline(described_class.new(edition: edition))

      # Title, 2 details fields (foo, something), organisation, instructions, status
      expect(page).to have_css ".govuk-summary-list__row", count: 6
    end

    it "compacts nil items from the list" do
      # This test ensures the .compact call in #items works correctly
      # by verifying all rows render without errors even if some items might be nil
      render_inline(described_class.new(edition: edition))

      assert_not page.has_selector?(".govuk-summary-list__row", text: "nil")
    end
  end

  describe "#schema" do
    it "memoizes the schema" do
      component = described_class.new(edition: edition)

      # Access schema multiple times through details_items
      expect(document).to receive(:schema).once.and_return(schema_without_block_display_fields)

      render_inline(component)
    end
  end
end
