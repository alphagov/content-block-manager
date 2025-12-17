RSpec.describe Shared::EmbeddedObjects, type: :component do
  include Rails.application.routes.url_helpers

  let(:details) do
    {
      "embedded-objects" => {
        "my-embedded-object" => {
          "name" => "My Embedded Object",
          "field-1" => "Value 1",
          "field-2" => "Value 2",
        },
        "another-embedded-object" => {
          "name" => "Another Embedded Object",
          "field-1" => "Value 1",
          "field-2" => "Value 2",
        },
      },
    }
  end

  let(:schema) { double(:schema) }
  let(:fields) do
    [
      build(:field, name: "field-1"),
      build(:field, name: "field-2"),
    ]
  end
  let(:subschema) { double(:subschema, block_type: "embedded-objects", name: "Embedded objects", fields:) }
  let(:document) { build(:document, :pension, schema:) }
  let(:edition) { build_stubbed(:edition, :pension, details:, document:) }
  let(:redirect_url) { "https://example.com" }

  let(:component) do
    Shared::EmbeddedObjectsComponent.new(
      edition:,
      subschema:,
      redirect_url:,
    )
  end

  before do
    allow(schema).to receive(:subschema).and_return(subschema)
  end

  it "renders all embedded objects of a particular type" do
    summary_card_double = double("summary_card")

    expect(Shared::EmbeddedObjects::SummaryCardComponent).to receive(:with_collection).with(
      %w[my-embedded-object another-embedded-object],
      edition: edition,
      object_type: subschema.block_type,
      redirect_url:,
      test_id_prefix: "embedded",
    ).and_return(summary_card_double)

    expect(component).to receive(:render).with(summary_card_double)

    render_inline(component)
  end

  it "shows a title" do
    render_inline(component)

    expect(page).to have_css "h2.govuk-heading-m", text: "Embedded Objects"
  end

  it "renders a button to add an object if the document is a new block" do
    expect(document).to receive(:is_new_block?).at_least(:once).and_return(true)

    render_inline(component)

    new_path = new_embedded_object_edition_path(
      edition,
      object_type: subschema.block_type,
    )

    expect(page).to have_css "a.govuk-button[href='#{new_path}']", text: I18n.t("buttons.add_another", item: "embedded object")
  end

  it "does not render a button to add an object if the document is not a new block" do
    expect(document).to receive(:is_new_block?).at_least(:once).and_return(false)

    render_inline(component)

    expect(page).to_not have_css "a.govuk-button", text: /embedded object/
  end

  describe "when no embedded objects are present" do
    let(:details) do
      {}
    end

    describe "when the document is a new block" do
      before do
        expect(document).to receive(:is_new_block?).at_least(:once).and_return(true)
      end

      it "renders the correct button text" do
        render_inline(component)

        new_path = new_embedded_object_edition_path(
          edition,
          object_type: subschema.block_type,
        )

        expect(page).to have_css "a.govuk-button[href='#{new_path}']", text: I18n.t("buttons.add", item: "an embedded object")
      end

      it "shows the title" do
        render_inline(component)

        expect(page).to have_css "h2.govuk-heading-m", text: "Embedded Objects"
      end
    end

    describe "when the document is not a new block" do
      before do
        expect(document).to receive(:is_new_block?).at_least(:once).and_return(false)
      end

      it "does not show the title" do
        render_inline(component)

        expect(page).to_not have_css "h2.govuk-heading-m", text: "Embedded Objects"
      end
    end
  end
end
