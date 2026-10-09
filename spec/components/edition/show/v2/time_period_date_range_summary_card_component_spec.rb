RSpec.describe Edition::Show::V2::TimePeriodDateRangeSummaryCardComponent, type: :component do
  let(:start_date) { Date.new(2026, 1, 5) }
  let(:end_date) { Date.new(2026, 12, 25) }
  let(:date_range) { double("DateRange", start: start_date, end: end_date) }

  let(:summary_card_actions) { [{ label: "Edit", href: "/edit" }] }

  subject(:component) do
    described_class.new(
      date_range: date_range,
      summary_card_actions: summary_card_actions,
    )
  end

  describe "attributes" do
    it "exposes summary_card_actions" do
      expect(component.summary_card_actions).to eq(summary_card_actions)
    end
  end

  describe "on render" do
    it "displays the expected title" do
      render_inline(component)

      expect(page).to have_text("Date range details")
    end
  end

  it "displays both dates without zero padding the day" do
    render_inline(component)

    expect(page).to have_summary_row
      .with_key("Start")
      .with_value("5 January 2026")
    expect(page).to have_summary_row
    .with_key("End")
    .with_value("25 December 2026")
  end
end
