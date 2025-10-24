RSpec.describe Document::EmbeddedObjects::New::SelectSubschemaComponent, type: :component do
  let(:heading) { "Some heading" }
  let(:heading_caption) { "Caption" }
  let(:error_message) { nil }
  let(:schemas) do
    [
      double(:schema, id: "foo", name: "Foos"),
      double(:schema, id: "bar", name: "Bars"),
      double(:schema, id: "baz", name: "Bazzes"),
    ]
  end

  let(:component) do
    described_class.new(
      heading:,
      heading_caption:,
      error_message:,
      schemas:,
    )
  end

  before do
    render_inline(component)
  end

  it "renders a select component with all the schemas" do
    expect(page).to have_css ".govuk-fieldset__heading", text: heading
    expect(page).to have_css ".govuk-caption-xl", text: heading_caption
    expect(page).to have_css ".govuk-radios__item", count: 3

    expect(page).not_to have_css ".govuk-error-message"

    radios = page.find ".govuk-radios"

    foo_item = radios.find ".govuk-radios__item", text: /Foo/
    expect(foo_item).to have_css "input[type='radio'][name='object_type'][value='foo']"
    expect(foo_item).to have_css ".govuk-radios__label", text: "Foo"

    bar_item = radios.find ".govuk-radios__item", text: /Bar/
    expect(bar_item).to have_css "input[type='radio'][name='object_type'][value='bar']"
    expect(bar_item).to have_css ".govuk-radios__label", text: "Bar"

    baz_item = radios.find ".govuk-radios__item", text: /Baz/
    expect(baz_item).to have_css "input[type='radio'][name='object_type'][value='baz']"
    expect(baz_item).to have_css ".govuk-radios__label", text: "Baz"
  end

  describe "when an error message is present" do
    let(:error_message) { "Some error" }

    it "shows the error message" do
      expect(page).to have_css ".govuk-error-message", text: error_message
    end
  end
end
