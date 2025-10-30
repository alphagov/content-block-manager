RSpec.describe Document::Index::DateFilterComponent, type: :component do
  it "renders from and to dates" do
    render_inline(described_class.new)
    expect(page).to have_css "input[name='last_updated_from[1i]']"
    expect(page).to have_css "input[name='last_updated_from[2i]']"
    expect(page).to have_css "input[name='last_updated_from[3i]']"

    expect(page).to have_css "input[name='last_updated_to[1i]']"
    expect(page).to have_css "input[name='last_updated_to[2i]']"
    expect(page).to have_css "input[name='last_updated_to[3i]']"
  end

  it "keeps the values from the filter params" do
    filters = {
      last_updated_from: {
        "3i" => "1",
        "2i" => "2",
        "1i" => "2025",
      },
      last_updated_to: {
        "3i" => "3",
        "2i" => "4",
        "1i" => "2026",
      },
    }
    render_inline(described_class.new(filters:))

    expect(page).to have_css "input[name='last_updated_from[3i]'][value=1]"
    expect(page).to have_css "input[name='last_updated_from[2i]'][value='2']"
    expect(page).to have_css "input[name='last_updated_from[1i]'][value='2025']"

    expect(page).to have_css "input[name='last_updated_to[3i]'][value='3']"
    expect(page).to have_css "input[name='last_updated_to[2i]'][value='4']"
    expect(page).to have_css "input[name='last_updated_to[1i]'][value='2026']"
  end

  it "renders errors if there are errors on the date filter" do
    errors = [
      Document::DocumentFilter::FILTER_ERROR.new(
        attribute: "last_updated_from", full_message: "From date is not in the correct format",
      ),
      Document::DocumentFilter::FILTER_ERROR.new(
        attribute: "last_updated_to", full_message: "To date is not in the correct format",
      ),
    ]
    render_inline(described_class.new(errors:))

    expect(page).to have_css ".govuk-error-message", text: "From date is not in the correct format"
    expect(page).to have_css ".govuk-error-message", text: "To date is not in the correct format"
  end
end
