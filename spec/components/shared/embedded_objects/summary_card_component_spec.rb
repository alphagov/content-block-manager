RSpec.describe Shared::EmbeddedObjects::SummaryCardComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:details) do
    {
      "embedded-objects" => {
        "my-embedded-object" => {
          "name" => "My Embedded Object",
          "field-2" => "Value 2",
          "field-1" => "Value 1",
        },
      },
    }
  end

  let(:schema) { double(:schema, block_type: "schema") }
  let(:fields) do
    [
      build(:field, name: "name", label: "Name"),
      build(:field, name: "field-1", label: "Field 1"),
      build(:field, name: "field-2", label: "Field 2"),
    ]
  end

  let(:subschema) do
    double(
      :subschema,
      block_display_fields: %w[name field-1 field-2],
      govspeak_enabled?: false,
      fields:,
      id: "subschema",
    )
  end

  let(:document) { build(:document, :pension, schema:) }
  let(:edition) { build_stubbed(:edition, :pension, details:, document:) }

  before do
    allow(schema).to receive(:subschema).and_return(subschema)
    fields.each do |field|
      allow(schema).to receive(:field).with(field.name).and_return(field)
    end
  end

  it "renders a summary list" do
    component = described_class.new(
      edition:,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
    )

    render_inline component

    expect(page).to have_css ".govuk-summary-card__title", text: "Embedded object details"

    expect(page).to have_css ".govuk-summary-list__row[data-testid='my_embedded_object_name']", text: /Name/ do
      expect(page).to have_css ".govuk-summary-list__key", text: "Name"
      expect(page).to have_css ".govuk-summary-list__value", text: "My Embedded Object"
    end

    expect(page).to have_css ".govuk-summary-list__row[data-testid='my_embedded_object_field_1']", text: /Field 1/ do
      expect(page).to have_css ".govuk-summary-list__key", text: "Field 1"
      expect(page).to have_css ".govuk-summary-list__value", text: "Value 1"
    end

    expect(page).to have_css ".govuk-summary-list__row[data-testid='my_embedded_object_field_2']", text: /Field 2/ do
      expect(page).to have_css ".govuk-summary-list__key", text: "Field 2"
      expect(page).to have_css ".govuk-summary-list__value", text: "Value 2"
    end
  end

  it "adds a data attribute if test_id_prefix is set" do
    component = described_class.new(
      edition:,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
      test_id_prefix: "prefix",
    )

    render_inline component

    expect(page).to have_css ".gem-c-summary-card[data-test-id='prefix_my-embedded-object']"
  end

  it "renders a summary list with a collection" do
    component = described_class.with_collection(
      %w[my-embedded-object],
      edition:,
      object_type: "embedded-objects",
    )

    render_inline component

    expect(page).to have_css ".govuk-summary-card__title", text: "Embedded object details"
    expect(page).to have_css ".govuk-summary-list__row", count: 3
  end

  it "uses the 'collection counter' feature of the ViewComponent in `object_title_counter` to render a numbered title" do
    component = described_class.new(
      object_title: "my-embedded-object",
      edition:,
      object_type: "embedded-objects",
      object_title_counter: 99,
    )

    render_inline component

    expect(page).to have_css ".govuk-summary-card__title", text: "Embedded object details 100"
  end

  it "renders a summary list with edit link" do
    component = described_class.new(
      edition:,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
    )

    render_inline component

    expect(page).to have_css ".govuk-summary-card__title", text: "Embedded object details"

    expected_edit_path = edit_embedded_object_edition_path(
      edition,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
    )

    expect(page).to have_css ".govuk-summary-list__row", count: 3

    expect(page).to have_css ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(1) a[href='#{expected_edit_path}']", text: "Edit"

    expect(page).to have_css ".govuk-summary-list__row", text: /Name/ do
      expect(page).to have_css ".govuk-summary-list__key", text: "Name"
      expect(page).to have_css ".govuk-summary-list__value", text: "My Embedded Object"
    end

    expect(page).to have_css ".govuk-summary-list__row", text: /Field 1/ do
      expect(page).to have_css ".govuk-summary-list__key", text: "Field 1"
      expect(page).to have_css ".govuk-summary-list__value", text: "Value 1"
    end

    expect(page).to have_css ".govuk-summary-list__row", text: /Field 2/ do
      expect(page).to have_css ".govuk-summary-list__key", text: "Field 2"
      expect(page).to have_css ".govuk-summary-list__value", text: "Value 2"
    end
  end

  it "renders a summary list with edit link and redirect url if provided" do
    component = described_class.new(
      edition:,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
      redirect_url: "https://example.com",
    )

    render_inline component

    expect(page).to have_css ".govuk-summary-card__title", text: "Embedded object details"

    expected_edit_path = edit_embedded_object_edition_path(
      edition,
      object_type: "embedded-objects",
      object_title: "my-embedded-object",
      redirect_url: "https://example.com",
    )

    expect(page).to have_css ".govuk-summary-card__actions .govuk-summary-card__action:nth-child(1) a[href='#{expected_edit_path}']", text: "Edit"
  end

  describe "when arrays are present" do
    let(:name_field) { build(:field, name: "name", label: "Name") }
    let(:field_field) { build(:field, name: "field", label: "Field") }

    let(:fields) do
      [
        name_field,
        field_field,
      ]
    end

    let(:details) do
      {
        "embedded-objects" => {
          "my-embedded-object" => {
            "name" => "My Embedded Object",
            "field" => %w[Foo Bar],
          },
        },
      }
    end

    it "renders a summary list" do
      component = described_class.new(
        edition:,
        object_type: "embedded-objects",
        object_title: "my-embedded-object",
      )

      render_inline component

      expect(page).to have_css ".govuk-summary-card__title", text: "Embedded object details"

      expect(page).to have_css ".govuk-summary-list__row[data-testid='my_embedded_object_name']", text: /Name/ do
        expect(page).to have_css ".govuk-summary-list__key", text: "Name"
        expect(page).to have_css ".govuk-summary-list__value", text: "My Embedded Object"
      end

      expect(page).to have_css ".govuk-summary-list__row[data-testid='my_embedded_object_field/0']", text: /Field 1/ do
        expect(page).to have_css ".govuk-summary-list__key", text: "Field 1"
        expect(page).to have_css ".govuk-summary-list__value", text: "Foo"
      end

      expect(page).to have_css ".govuk-summary-list__row[data-testid='my_embedded_object_field/1']", text: /Field 2/ do
        expect(page).to have_css ".govuk-summary-list__key", text: "Field 2"
        expect(page).to have_css ".govuk-summary-list__value", text: "Bar"
      end
    end

    describe "when arrays are present with hashes" do
      let(:name_field) { build(:field, name: "name", label: "Name") }
      let(:field_field) { build(:field, name: "field", title: "Field") }

      let(:fields) do
        [
          name_field,
          field_field,
        ]
      end

      let(:details) do
        {
          "embedded-objects" => {
            "my-embedded-object" => {
              "name" => "My Embedded Object",
              "field" => [{ item: "Foo" }, { item: "Bar" }],
            },
          },
        }
      end

      let(:item_field) { build(:field, name: "item", govspeak_enabled?: false, label: "Item") }

      before do
        allow(field_field).to receive(:nested_field).with("item").and_return(item_field)
      end

      it "renders a nested summary card" do
        component = described_class.new(
          edition:,
          object_type: "embedded-objects",
          object_title: "my-embedded-object",
        )

        render_inline component

        expect(page).to have_css ".govuk-summary-card__title", text: "Embedded object details"

        expect(page).to have_css ".govuk-summary-list__row[data-testid='my_embedded_object_name']", text: /Name/ do
          expect(page).to have_css ".govuk-summary-list__key", text: "Name"
          expect(page).to have_css ".govuk-summary-list__value", text: "My Embedded Object"
        end

        expect(page).to have_css ".app-c-content-block-manager-nested-item-component", text: /Field 1/ do |_nested_block|
          expect(page).to have_css ".govuk-summary-card__title", text: "Field 1"
          expect(page).to have_css ".govuk-summary-list__key", text: "Item"
          expect(page).to have_css ".govuk-summary-list__value", text: "Foo"
        end

        expect(page).to have_css ".app-c-content-block-manager-nested-item-component", text: /Field 2/ do |_nested_block|
          expect(page).to have_css ".govuk-summary-card__title", text: "Field 2"
          expect(page).to have_css ".govuk-summary-list__key", text: "Item"
          expect(page).to have_css ".govuk-summary-list__value", text: "Bar"
        end
      end
    end

    describe "when hashes are present" do
      let(:name_field) { build(:field, name: "name", label: "Name") }
      let(:field_field) { build(:field, name: "field", title: "Field") }

      let(:fields) do
        [
          name_field,
          field_field,
        ]
      end

      let(:details) do
        {
          "embedded-objects" => {
            "my-embedded-object" => {
              "name" => "My Embedded Object",
              "field" => { item: "Foo" },
            },
          },
        }
      end

      let(:item_field) { build(:field, name: "item", govspeak_enabled?: false, label: "Item") }

      before do
        allow(field_field).to receive(:nested_field).with("item").and_return(item_field)
      end

      it "renders a nested summary card" do
        component = described_class.new(
          edition:,
          object_type: "embedded-objects",
          object_title: "my-embedded-object",
        )

        render_inline component

        expect(page).to have_css ".govuk-summary-card__title", text: "Embedded object details"

        expect(page).to have_css ".govuk-summary-list__row[data-testid='my_embedded_object_name']", text: /Name/ do
          expect(page).to have_css ".govuk-summary-list__key", text: "Name"
          expect(page).to have_css ".govuk-summary-list__value", text: "My Embedded Object"
        end

        expect(page).to have_css ".app-c-content-block-manager-nested-item-component", text: /Field/ do |_nested_block|
          expect(page).to have_css ".govuk-summary-card__title", text: "Field"
          expect(page).to have_css ".govuk-summary-list__key", text: "Item"
          expect(page).to have_css ".govuk-summary-list__value", text: "Foo"
        end
      end
    end
  end
end
