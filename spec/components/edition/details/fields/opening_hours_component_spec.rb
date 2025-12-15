RSpec.describe Edition::Details::Fields::OpeningHoursComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::OpeningHoursComponent }
  let(:helper_stub) { double(:helpers) }

  let(:edition) { build(:edition, :contact) }

  let(:properties) do
    {
      "opening_hours" => {
        "type" => "object",
        "properties" => {
          "show_opening_hours" => {
            "type" => "boolean", "default" => false
          },
          "opening_hours" => {
            "type" => "string",
          },
        },
      },
    }
  end

  let(:body) do
    {
      "type" => "object",
      "patternProperties" => {
        "*" => {
          "type" => "object",
          "properties" => properties,
        },
      },
    }
  end

  let(:parent_schema) { double(:schema, id: "parent_schema_id") }
  let(:subschema) do
    Schema::EmbeddedSchema.new(
      "telephones",
      body,
      parent_schema,
    )
  end

  let(:schema) { double(:schema, block_type: "schema") }

  let(:field) do
    Schema::Field.new(
      "opening_hours",
      subschema,
    )
  end

  let(:field_value) do
    { "show_opening_hours" => nil,
      "opening_hours" => nil }
  end

  let(:component) do
    described_class.new(
      edition:,
      field: field,
      value: field_value,
      schema: schema,
      subschema: subschema,
    )
  end

  before do
    allow(component).to receive(:helpers).and_return(helper_stub)
    allow(helper_stub).to receive(:humanized_label).and_return("Label")
  end

  describe "Opening hours component" do
    describe "show nested field" do
      it "shows a checkbox to toggle 'Show Opening Hours' option" do
        allow(helper_stub).to receive(:humanized_label).and_return("Show opening hours?")

        render_inline(component)

        expect(page).to have_css(".govuk-checkboxes") do |component|
          expect(component).to have_css("label", text: "Show opening hours?")
        end
      end

      context "when the 'show_opening_hours' value is true" do
        let(:field_value) do
          { "show_opening_hours" => true,
            "opening_hours" => nil }
        end

        it "sets the checkbox to _checked_" do
          render_inline(component)

          expect(page).to have_css(".govuk-checkboxes") do |component|
            expect(component).to have_css("input[checked='checked']")
          end
        end
      end

      context "when the 'show_opening_hours' value is false" do
        let(:field_value) do
          { "show_opening_hours" => false,
            "opening_hours" => nil }
        end

        it "sets the checkbox to _unchecked_" do
          render_inline(component)

          expect(page).to have_css(".govuk-checkboxes") do |component|
            component.assert_no_selector("input[checked='checked']")
          end
        end
      end
    end

    describe "'opening_hours' nested field" do
      context "when a value is set for the 'opening_hours'" do
        let(:field_value) do
          { "show_opening_hours" => true,
            "opening_hours" => "CUSTOM VALUE" }
        end

        it "displays that value in the input field" do
          render_inline(component)

          expect(page).to have_css(".govuk-checkboxes") do |component|
            expect(component).to have_css(
              "textarea" \
                "[name='edition[details][telephones][opening_hours][opening_hours]']",
              text: "CUSTOM VALUE",
            )
          end
        end
      end
    end
  end
end
