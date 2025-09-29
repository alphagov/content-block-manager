require "test_helper"

class Edition::HostContent::TableComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  let(:described_class) { Edition::HostContent::TableComponent }
  let(:caption) { "Some caption" }
  let(:publishing_organisation) do
    {
      "content_id" => SecureRandom.uuid,
      "title" => "bar",
      "base_path" => "/bar",
    }
  end
  let(:unique_pageviews) { 1_200_000 }

  let(:last_edited_by_editor) { build(:signon_user) }
  let(:host_content_item) do
    HostContentItem.new(
      "title" => "Some title",
      "base_path" => "/foo",
      "document_type" => "document_type",
      "publishing_app" => "publisher",
      "last_edited_by_editor" => last_edited_by_editor,
      "last_edited_at" => Time.zone.now.to_s,
      "publishing_organisation" => publishing_organisation,
      "unique_pageviews" => unique_pageviews,
      "host_content_id" => SecureRandom.uuid,
      "host_locale" => "en",
      "instances" => 1,
    )
  end
  let(:host_content_items) do
    build(
      :host_content_items,
      items: [host_content_item],
      total: 20,
      total_pages: 2,
    )
  end

  let(:edition) do
    build(:edition, :pension, id: SecureRandom.uuid)
  end

  around do |test|
    with_request_url root_path do
      test.call
    end
  end

  before do
    render_inline(
      described_class.new(
        caption:,
        host_content_items:,
        edition:,
      ),
    )
  end

  it "shows the title as unlinked" do
    assert_selector "tbody .govuk-table__cell", text: host_content_item.title
  end

  it "shows the preview link" do
    assert_selector "tbody .govuk-table__cell a.govuk-link", text: "Preview #{host_content_item.title} (opens in new tab)" do |link|
      assert_equal host_content_preview_edition_path(id: edition.id, host_content_id: host_content_item.host_content_id, locale: host_content_item.host_locale), link[:href]
      assert_equal "noopener", link[:rel]
      assert_equal "_blank", link[:target]
    end
  end

  it "shows the correct headers" do
    assert_selector ".govuk-table__header", text: "Title"
    assert_selector ".govuk-table__header", text: "Title"
    assert_selector ".govuk-table__header", text: "Type"
    assert_selector ".govuk-table__header", text: "Views (30 days)"
    assert_selector ".govuk-table__header", text: "Instances"
    assert_selector ".govuk-table__header", text: "Lead organisation"
    assert_selector ".govuk-table__header", text: "Preview (opens in new tab)"
  end
end
