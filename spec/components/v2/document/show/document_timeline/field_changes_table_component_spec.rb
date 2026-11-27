RSpec.describe V2::Document::Show::DocumentTimeline::FieldChangesTableComponent, type: :component do
  let(:user) { build_stubbed(:user) }
  let(:edition) { create(:v2_time_period_edition) }

  context "when the changes include changes to 'to_details' fields" do
    it "renders the edition diff table with all the updated fields in the correct order" do
      field_diffs = {
        "title" => DiffItem.new(previous_value: "old title", new_value: "new title"),
        "details" => {
          "description" => DiffItem.new(previous_value: "the old description", new_value: "the new description"),
          "date_range" => {
            "start" => DiffItem.new(previous_value: "2025-02-01", new_value: "2027-02-01"),
          },
        },
        "instructions_to_publishers" => DiffItem.new(previous_value: "old instructions", new_value: "new instructions"),
      }

      version = build(
        :v2_version,
        event: "updated",
        whodunnit: user.id,
        state: "published",
        field_diffs: field_diffs,
        item: edition,
      )

      render_inline(
        described_class.new(version:),
      )

      expect(page).to have_css "tr:nth-child(1) th:nth-child(1)", text: "Time period name"
      expect(page).to have_css "tr:nth-child(1) td:nth-child(2)", text: "old title"
      expect(page).to have_css "tr:nth-child(1) td:nth-child(3)", text: "new title"

      expect(page).to have_css "tr:nth-child(2) th:nth-child(1)", text: "Description"
      expect(page).to have_css "tr:nth-child(2) td:nth-child(2)", text: "the old description"
      expect(page).to have_css "tr:nth-child(2) td:nth-child(3)", text: "the new description"

      expect(page).to have_css "tr:nth-child(3) th:nth-child(1)", text: "Date range start"
      expect(page).to have_css "tr:nth-child(3) td:nth-child(2)", text: "2025-02-01"
      expect(page).to have_css "tr:nth-child(3) td:nth-child(3)", text: "2027-02-01"

      expect(page).to have_css "tr:nth-child(4) th:nth-child(1)", text: "Instructions to publishers"
      expect(page).to have_css "tr:nth-child(4) td:nth-child(2)", text: "old instructions"
      expect(page).to have_css "tr:nth-child(4) td:nth-child(3)", text: "new instructions"
    end
  end

  context "when the changes do not include changes to the 'to_details' fields" do
    it "renders the edition diff table with only the updated fields displaying" do
      field_diffs = {
        "title" => DiffItem.new(previous_value: "old title", new_value: "new title"),
        "instructions_to_publishers" => DiffItem.new(previous_value: "old instructions", new_value: "new instructions"),
      }

      version = build(
        :v2_version,
        event: "updated",
        whodunnit: user.id,
        state: "published",
        field_diffs: field_diffs,
        item: edition,
      )

      render_inline(
        described_class.new(version:),
      )

      expect(page).to have_css "tr:nth-child(1) th:nth-child(1)", text: "Time period name"
      expect(page).to have_css "tr:nth-child(1) td:nth-child(2)", text: "old title"
      expect(page).to have_css "tr:nth-child(1) td:nth-child(3)", text: "new title"

      expect(page).to have_css "tr:nth-child(2) th:nth-child(1)", text: "Instructions to publishers"
      expect(page).to have_css "tr:nth-child(2) td:nth-child(2)", text: "old instructions"
      expect(page).to have_css "tr:nth-child(2) td:nth-child(3)", text: "new instructions"

      expect(page).to_not have_css "tr:nth-child(3)"
    end
  end
end
