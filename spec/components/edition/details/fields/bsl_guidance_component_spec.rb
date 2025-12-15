RSpec.describe Edition::Details::Fields::BSLGuidanceComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::BSLGuidanceComponent }

  let(:edition) { build(:edition, :contact) }
  let(:helper_stub) { double(:helpers) }

  let(:properties) do
    {
      "bsl_guidance" => {
        "type" => "object",
        "properties" => {
          "value" => { "type" => "string", "default" => "DEFAULT VALUE" },
          "show" => { "type" => "boolean", "default" => false },
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

  let(:field) do
    Schema::Field.new(
      "bsl_guidance",
      subschema,
    )
  end

  let(:field_value) do
    { "show" => nil,
      "value" => nil }
  end

  let(:schema) { double(:schema, block_type: "schema") }

  let(:component) do
    described_class.new(
      edition:,
      field: field,
      schema:,
      value: field_value,
      subschema: subschema,
    )
  end

  before do
    allow(component).to receive(:helpers).and_return(helper_stub)
    allow(helper_stub).to receive(:hint_text).and_return(nil)
    allow(helper_stub).to receive(:humanized_label).and_return("Translated label")
  end

  describe "BSL Guidance component" do
    describe "'show' nested field" do
      it "shows a checkbox to toggle 'Show BSL Guidance' option" do
        allow(helper_stub).to receive(:humanized_label).and_return("Show BSL Guidance?")

        render_inline(component)

        expect(page).to have_css(".app-c-content-block-manager-bsl-guidance-component") do |component|
          expect(component).to have_css("label", text: "Show BSL Guidance?")
        end
      end

      context "when the 'show' value is true" do
        let(:field_value) do
          { "value" => nil,
            "show" => true }
        end

        it "sets the checkbox to _checked_" do
          render_inline(component)

          expect(page).to have_css(".app-c-content-block-manager-bsl-guidance-component") do |component|
            expect(component).to have_css("input[checked='checked']")
          end
        end
      end

      context "when the 'show' value is false" do
        let(:field_value) do
          { "value" => nil,
            "show" => false }
        end

        it "sets the checkbox to _unchecked_" do
          render_inline(component)

          expect(page).to have_css(".app-c-content-block-manager-bsl-guidance-component") do |component|
            expect(component).to_not have_css("input[checked='checked']")
          end
        end
      end

      context "when the 'show' value is nil" do
        let(:field_value) do
          { "value" => nil,
            "show" => nil }
        end

        it "sets the checkbox to _unchecked_" do
          render_inline(component)

          expect(page).to have_css(".app-c-content-block-manager-bsl-guidance-component") do |component|
            expect(component).to_not have_css("input[checked='checked']")
          end
        end
      end

      context "when the 'show' field has related hint text" do
        it "shows the hint text" do
          allow(component).to receive(:hint_text).and_return({ show: "Some hint text" })

          render_inline(component)

          expect(page).to have_css(".app-c-content-block-manager-bsl-guidance-component") do |component|
            expect(component).to have_css(".govuk-checkboxes__item .govuk-hint", text: "Some hint text")
          end
        end
      end

      context "when the 'show' does not have related hint text" do
        it "shows the hint text" do
          allow(component).to receive(:hint_text).and_return(nil)

          render_inline(component)

          expect(page).to have_css(".app-c-content-block-manager-bsl-guidance-component") do |component|
            expect(component).to_not have_css(".govuk-checkboxes__item .govuk-hint")
          end
        end
      end
    end

    describe "'value' nested field" do
      context "when a value is set for the 'value'" do
        let(:field_value) do
          { "show" => nil,
            "value" => "CUSTOM VALUE" }
        end

        it "displays that value in the input field" do
          render_inline(component)

          expect(page).to have_css(".app-c-content-block-manager-bsl-guidance-component") do |component|
            expect(component).to have_css(
              "textarea" \
              "[name='edition[details][telephones][bsl_guidance][value]']",
              text: "CUSTOM VALUE",
            )
          end
        end
      end
    end
  end
end
