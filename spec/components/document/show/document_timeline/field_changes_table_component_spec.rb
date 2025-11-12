RSpec.describe Document::Show::DocumentTimeline::FieldChangesTableComponent, type: :component do
  let(:user) { build_stubbed(:user) }
  let(:schema) { double(:schema, fields: %w[email_address]) }

  it "renders the edition diff table in correct order" do
    field_diffs = {
      "title" => DiffItem.new(previous_value: "old title", new_value: "new title"),
      "details" => {
        "email_address" => DiffItem.new(previous_value: "old@email.com", new_value: "new@email.com"),
      },
      "instructions_to_publishers" => DiffItem.new(previous_value: "old instructions", new_value: "new instructions"),
    }
    version = build(
      :content_block_version,
      event: "updated",
      whodunnit: user.id,
      state: "published",
      field_diffs: field_diffs,
    )

    render_inline(
      described_class.new(
        version:,
        schema:,
      ),
    )

    expect(page).to have_css "tr:nth-child(1) th:nth-child(1)", text: "Title"
    expect(page).to have_css "tr:nth-child(1) td:nth-child(2)", text: "old title"
    expect(page).to have_css "tr:nth-child(1) td:nth-child(3)", text: "new title"

    expect(page).to have_css "tr:nth-child(2) th:nth-child(1)", text: "Email address"
    expect(page).to have_css "tr:nth-child(2) td:nth-child(2)", text: "old@email.com"
    expect(page).to have_css "tr:nth-child(2) td:nth-child(3)", text: "new@email.com"

    expect(page).to have_css "tr:nth-child(3) th:nth-child(1)", text: "Instructions to publishers"
    expect(page).to have_css "tr:nth-child(3) td:nth-child(2)", text: "old instructions"
    expect(page).to have_css "tr:nth-child(3) td:nth-child(3)", text: "new instructions"
  end
end
