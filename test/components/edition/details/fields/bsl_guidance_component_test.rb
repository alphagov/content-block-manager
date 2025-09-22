require "test_helper"

class Edition::Details::Fields::BSLGuidanceComponentTest < BaseComponentTestClass
  let(:described_class) { Edition::Details::Fields::BSLGuidanceComponent }

  let(:edition) { build(:edition, :contact) }

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

  let(:subschema) do
    Schema::EmbeddedSchema.new(
      "telephones",
      body,
      "parent_schema_id",
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

  let(:schema) { stub(:schema, block_type: "schema") }

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
    Edition::Details::Fields::TextareaComponent.any_instance.stubs(:helpers).returns(helper_stub)
  end

  describe "BSL Guidance component" do
    describe "'show' nested field" do
      it "shows a checkbox to toggle 'Show BSL Guidance' option" do
        helper_stub.stubs(:humanized_label).returns("Show BSL Guidance?")

        render_inline(component)

        assert_selector(".app-c-content-block-manager-bsl-guidance-component") do |component|
          component.assert_selector("label", text: "Show BSL Guidance?")
        end
      end

      context "when the 'show' value is true" do
        let(:field_value) do
          { "value" => nil,
            "show" => true }
        end

        it "sets the checkbox to _checked_" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-bsl-guidance-component") do |component|
            component.assert_selector("input[checked='checked']")
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

          assert_selector(".app-c-content-block-manager-bsl-guidance-component") do |component|
            component.assert_no_selector("input[checked='checked']")
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

          assert_selector(".app-c-content-block-manager-bsl-guidance-component") do |component|
            component.assert_no_selector("input[checked='checked']")
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

          assert_selector(".app-c-content-block-manager-bsl-guidance-component") do |component|
            component.assert_selector(
              "textarea" \
              "[name='edition[details][telephones][bsl_guidance][value]']",
              text: "CUSTOM VALUE",
            )
          end
        end
      end

      context "when a value is NOT set for the 'value'" do
        let(:field_value) do
          { "show" => nil,
            "value" => nil }
        end

        it "displays the default value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-bsl-guidance-component") do |component|
            component.assert_selector(
              "textarea" \
              "[name='edition[details][telephones][bsl_guidance][value]']",
              text: "DEFAULT VALUE",
            )
          end
        end
      end
    end
  end
end
