RSpec.describe Shared::EmbeddedObject::SummaryCardComponent, type: :component do
  include Rails.application.routes.url_helpers

  context "when a field's schema is not configured to be embeddable as a block" do
    let(:non_embeddable_field_schema) do
      instance_double(Schema::EmbeddedSchema, embeddable_as_block?: false)
    end

    let(:non_embeddable_field) do
      instance_double(
        Schema::Field,
        name: "plain_text",
        label: "Plain text",
        schema: non_embeddable_field_schema,
      )
    end

    let(:subschema) do
      instance_double(
        Schema::EmbeddedSchema,
        fields: [non_embeddable_field],
        field: non_embeddable_field,
      )
    end

    let(:root_schema) { instance_double(Schema) }
    let(:document) { instance_double(Document, schema: root_schema) }
    let(:edition) do
      instance_double(
        Edition,
        details: { "test_object" => { "plain_text" => "value" } }, document:,
      )
    end

    before do
      allow(subschema).to receive(:field).with("plain_text").and_return(non_embeddable_field)
      allow(root_schema).to receive(:subschema).with("test_object").and_return(subschema)
    end

    it "raises ArgumentError" do
      component = described_class.new(edition:, object_type: "test_object")

      expect { render_inline(component) }
        .to raise_error(ArgumentError, "Field 'plain_text' must be embeddable")
    end
  end

  context "when the embedded object has datetime string fields, as within TimePeriod#date_range" do
    let(:details) do
      {
        "date_range" => {
          "start" => "2025-04-06T00:00:00+01:00",
          "end" => "2026-04-05T23:59:00+01:00",
        },
      }
    end

    let(:document) { build(:document, :time_period) }
    let(:edition) { build_stubbed(:edition, :time_period, details:, document:) }

    let(:component) { described_class.new(edition:, object_type: "date_range") }

    before do
      %w[date_range/start date_range/end].each do |field_path|
        allow(edition).to receive(:render)
          .with(edition.document.embed_code_for_field(field_path))
          .and_return("FORMATTED_DATETIME")
      end
    end

    it "renders the datetime values as formatted strings" do
      render_inline component

      expect(page).to have_css ".govuk-summary-card__title", text: "Date range details"

      expect(page).to have_css(".govuk-summary-list") do |list|
        expect(list).to have_summary_row.with_key("Start").with_value("FORMATTED_DATETIME")
        expect(list).to have_summary_row.with_key("End").with_value("FORMATTED_DATETIME")
      end
    end

    it "includes a single 'Edit' link to edit the whole object" do
      render_inline component

      expected_edit_path = edit_sole_embedded_object_edition_path(
        edition,
        object_type: "date_range",
      )

      expect(page).to have_css ".govuk-summary-card__title-wrapper" do |title|
        expect(title).to have_css ".govuk-summary-card__action" do |action|
          expect(action).to have_css(
            "a[href='#{expected_edit_path}']",
            text: "Edit Date range details",
          )
        end
      end
    end
  end
end
