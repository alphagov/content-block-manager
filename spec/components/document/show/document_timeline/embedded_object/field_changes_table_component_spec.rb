RSpec.describe Document::Show::DocumentTimeline::EmbeddedObject::FieldChangesTableComponent, type: :component do
  let(:field_diff) do
    {
      "email_address" => DiffItem.new(previous_value: "old@email.com", new_value: "new@email.com"),
      "object" => {
        "something" => DiffItem.new(previous_value: "old value", new_value: "new value"),
      },
    }
  end

  let(:edition) do
    build(:edition, details: { "my_subschema" => { "something" => { "title" => "My thing" } } })
  end

  it "renders the edition diff table" do
    render_inline(
      described_class.new(
        object_id: "something",
        field_diff:,
        subschema_id: "my_subschema",
        edition:,
      ),
    )

    expect(page).to have_css ".govuk-table__caption", text: "My thing"

    expect(page).to have_css "tr:nth-child(1) th:nth-child(1)", text: "Email address"
    expect(page).to have_css "tr:nth-child(1) td:nth-child(2)", text: "old@email.com"
    expect(page).to have_css "tr:nth-child(1) td:nth-child(3)", text: "new@email.com"

    expect(page).to have_css "tr:nth-child(2) th:nth-child(1)", text: "Object something"
    expect(page).to have_css "tr:nth-child(2) td:nth-child(2)", text: "old value"
    expect(page).to have_css "tr:nth-child(2) td:nth-child(3)", text: "new value"
  end

  describe "when a title cannot be found for the object" do
    let(:edition) do
      build(:edition, details: {})
    end

    it "humanizes the object ID" do
      render_inline(
        described_class.new(
          object_id: "something",
          field_diff:,
          subschema_id: "my_subschema",
          edition:,
        ),
      )

      expect(page).to have_css ".govuk-table__caption", text: "Something"
    end
  end
end
