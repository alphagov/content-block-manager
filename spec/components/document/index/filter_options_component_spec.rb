RSpec.describe Document::Index::FilterOptionsComponent, type: :component do
  let(:helper_mock) { double }

  let(:schemas) do
    [
      build(:schema, :pension),
      build(:schema, :contact),
    ]
  end

  before do
    allow_any_instance_of(described_class).to receive(:helpers).and_return(helper_mock)
    allow(helper_mock).to receive(:content_block_manager).and_return(helper_mock)
    allow(helper_mock).to receive(:documents_path).and_return("path")
    allow(helper_mock).to receive(:root_path).and_return("path")

    allow(helper_mock).to receive(:taggable_organisations_container).and_return([
      { text: "Department of Placeholder", value: 1 },
      { text: "Ministry of Example", value: 2 },
    ])

    allow(helper_mock).to receive(:valid_schemas).and_return(schemas)
  end

  it "expands all sections by default" do
    render_inline(
      described_class.new(
        filters: {},
      ),
    )
    expect(page).to have_css ".govuk-accordion__section--expanded", count: 4
  end

  it "adds value of keyword to text input from filter" do
    render_inline(
      described_class.new(
        filters: { keyword: "ministry defense" },
      ),
    )

    expect(page).to have_css ".govuk-accordion__section--expanded", text: "Keyword"
    expect(page).to have_css "input[name='keyword'][type='search'][value='ministry defense']"
  end

  it "renders checkbox items for all valid schemas" do
    render_inline(
      described_class.new(
        filters: {},
      ),
    )

    expect(page).to have_css "input[type='checkbox'][name='block_type[]'][value='pension']"
    expect(page).to have_css "input[type='checkbox'][name='block_type[]'][value='contact']"
  end

  it "checks checkbox items if checked in filters" do
    render_inline(
      described_class.new(
        filters: { block_type: %w[pension] },
      ),
    )

    expect(page).to have_css ".govuk-accordion__section--expanded", text: "Content block type"

    expect(page).to have_css "input[type='checkbox'][name='block_type[]'][value='pension'][checked]"
    expect(page).to have_css "input[type='checkbox'][name='block_type[]'][value='contact']"
  end

  it "returns organisations with an 'all organisations' option" do
    render_inline(described_class.new(filters: {}))

    expect(page).to have_css "select[name='lead_organisation']"
    expect(page).to have_css "option[selected='selected'][value='']"
  end

  it "selects organisation if selected in filters" do
    allow(helper_mock).to receive(:taggable_organisations_container).and_return([
      { text: "Department of Placeholder", value: 1 },
      { text: "Ministry of Example", value: 2, selected: true },
    ])
    render_inline(
      described_class.new(
        filters: { lead_organisation: "2" },
      ),
    )

    expect(page).to have_css ".govuk-accordion__section--expanded", text: "Lead organisation"

    expect(page).to have_css "select[name='lead_organisation']"
    expect(page).to have_css "option[selected='selected'][value=2]"
  end

  it "passes filters and errors to Date component" do
    filters = { lead_organisation: "2" }
    errors = [
      Document::DocumentFilter::FILTER_ERROR.new(
        attribute: "last_updated_from", full_message: "From date is not in the correct format",
      ),
    ]
    date_component = Document::Index::DateFilterComponent.new(filters:, errors:)
    expect(Document::Index::DateFilterComponent).to receive(:new).with(filters:, errors:)
                                                                           .and_return(date_component)

    render_inline(
      described_class.new(
        filters:,
        errors:,
      ),
    )

    expect(page).to have_css ".govuk-accordion__section--expanded", text: "Last updated date"
  end

  it "adds the relevant GA4 data attributes" do
    render_inline(
      described_class.new(
        filters: {},
      ),
    )

    expect(page).to have_css "form", count: 1

    expect(page).to have_css "form[data-module='ga4-search-tracker']"
    expect(page).to have_css "form[data-ga4-search-type='index-documents']"
    expect(page).to have_css "form[data-ga4-search-url='#{helper_mock.documents_path}']"
    expect(page).to have_css "form[data-ga4-search-section='#{I18n.t('document.index.filter_options.heading')}']"
    expect(page).to have_css "form[data-ga4-search-input-name='keyword']"
  end
end
