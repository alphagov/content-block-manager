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
end
