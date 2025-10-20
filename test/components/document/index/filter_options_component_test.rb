require "test_helper"

class Document::Index::FilterOptionsComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:helper_mock) { mock }

  before do
    Document::Index::FilterOptionsComponent.any_instance.stubs(:helpers).returns(helper_mock)
    helper_mock.stubs(:content_block_manager).returns(helper_mock)
    helper_mock.stubs(:documents_path).returns("path")
    helper_mock.stubs(:root_path).returns("path")

    helper_mock.stubs(:taggable_organisations_container).returns([
      { text: "Department of Placeholder", value: 1 },
      { text: "Ministry of Example", value: 2 },
    ])

    Schema.stubs(:valid_schemas).returns(%w[pension contact])
  end

  it "expands all sections by default" do
    render_inline(
      Document::Index::FilterOptionsComponent.new(
        filters: {},
      ),
    )
    assert_selector ".govuk-accordion__section--expanded", count: 4
  end

  it "adds value of keyword to text input from filter" do
    render_inline(
      Document::Index::FilterOptionsComponent.new(
        filters: { keyword: "ministry defense" },
      ),
    )

    assert_selector ".govuk-accordion__section--expanded", text: "Keyword"
    assert_selector "input[name='keyword'][type='search'][value='ministry defense']"
  end

  it "renders checkbox items for all valid schemas" do
    render_inline(
      Document::Index::FilterOptionsComponent.new(
        filters: {},
      ),
    )

    assert_selector "input[type='checkbox'][name='block_type[]'][value='pension']"
    assert_selector "input[type='checkbox'][name='block_type[]'][value='contact']"
  end

  it "checks checkbox items if checked in filters" do
    render_inline(
      Document::Index::FilterOptionsComponent.new(
        filters: { block_type: %w[pension] },
      ),
    )

    assert_selector ".govuk-accordion__section--expanded", text: "Content block type"

    assert_selector "input[type='checkbox'][name='block_type[]'][value='pension'][checked]"
    assert_selector "input[type='checkbox'][name='block_type[]'][value='contact']"
  end

  it "returns organisations with an 'all organisations' option" do
    render_inline(Document::Index::FilterOptionsComponent.new(filters: {}))

    assert_selector "select[name='lead_organisation']"
    assert_selector "option[selected='selected'][value='']"
  end

  it "selects organisation if selected in filters" do
    helper_mock.stubs(:taggable_organisations_container).returns([
      { text: "Department of Placeholder", value: 1 },
      { text: "Ministry of Example", value: 2, selected: true },
    ])
    render_inline(
      Document::Index::FilterOptionsComponent.new(
        filters: { lead_organisation: "2" },
      ),
    )

    assert_selector ".govuk-accordion__section--expanded", text: "Lead organisation"

    assert_selector "select[name='lead_organisation']"
    assert_selector "option[selected='selected'][value=2]"
  end

  it "passes filters and errors to Date component" do
    filters = { lead_organisation: "2" }
    errors = [
      Document::DocumentFilter::FILTER_ERROR.new(
        attribute: "last_updated_from", full_message: "From date is not in the correct format",
      ),
    ]
    date_component = Document::Index::DateFilterComponent.new(filters:, errors:)
    Document::Index::DateFilterComponent.expects(:new).with(filters:, errors:)
                                                                           .returns(date_component)

    render_inline(
      Document::Index::FilterOptionsComponent.new(
        filters:,
        errors:,
      ),
    )

    assert_selector ".govuk-accordion__section--expanded", text: "Last updated date"
  end

  it "adds the relevant GA4 data attributes" do
    render_inline(
      Document::Index::FilterOptionsComponent.new(
        filters: {},
      ),
    )

    assert_selector "form", count: 1

    assert_selector "form[data-module='ga4-search-tracker']"
    assert_selector "form[data-ga4-search-type='index-documents']"
    assert_selector "form[data-ga4-search-url='#{helper_mock.documents_path}']"
    assert_selector "form[data-ga4-search-section='#{I18n.t('document.index.filter_options.heading')}']"
    assert_selector "form[data-ga4-search-input-name='keyword']"
  end
end
