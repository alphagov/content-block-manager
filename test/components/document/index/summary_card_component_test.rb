require "test_helper"

class Document::Index::SummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  include Rails.application.routes.url_helpers

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::SanitizeHelper
  include EditionHelper

  let(:document) { build_stubbed(:document, :pension) }
  let(:organisation) { build(:organisation) }
  let(:edition) do
    build_stubbed(
      :edition,
      :pension,
      id: 123,
      details: { foo: "bar", something: "else" },
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
      stub(:field, name: "foo"),
      stub(:field, name: "something"),
    ]
  end
  let(:schema) { stub(:schema, fields:) }

  before do
    document.stubs(:latest_edition).at_least_once.returns(edition)
    edition.stubs(:schema).returns(schema)
    Organisation.stubs(:all).returns([organisation])
  end

  it "renders a published content block as a summary card" do
    render_inline(Document::Index::SummaryCardComponent.new(document:))

    assert_selector ".govuk-summary-card__title", text: edition.title
    assert_selector ".govuk-summary-card__action", count: 1
    assert_selector ".govuk-summary-card__action .govuk-link[href='#{document_path(document)}']"

    assert_selector ".govuk-link", text: "View"

    assert_selector ".govuk-summary-list__row", count: 5

    assert_selector ".govuk-summary-list__key", text: "Title"
    assert_selector ".govuk-summary-list__value", text: edition.title

    assert_selector ".govuk-summary-list__key", text: "Foo"
    assert_selector ".govuk-summary-list__value", text: "bar"

    assert_selector ".govuk-summary-list__key", text: "Something"
    assert_selector ".govuk-summary-list__value", text: "else"

    assert_selector ".govuk-summary-list__key", text: "Lead organisation"
    assert_selector ".govuk-summary-list__value", text: edition.lead_organisation.name

    assert_selector ".govuk-summary-list__key", text: "Status"
    assert_selector ".govuk-summary-list__value", text: "Published on #{strip_tags published_date(edition)} by #{edition.creator.name}"
  end

  describe "when the edition is scheduled" do
    it "returns the scheduled value" do
      edition.state = "scheduled"
      edition.scheduled_publication = Time.zone.now

      render_inline(Document::Index::SummaryCardComponent.new(document:))

      assert_selector ".govuk-summary-list__row", count: 5

      assert_selector ".govuk-summary-list__key", text: "Status"
      assert_selector ".govuk-summary-list__value", text: "Scheduled for publication at #{strip_tags scheduled_date(edition)}"
    end
  end
end
