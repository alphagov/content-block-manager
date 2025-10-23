require "test_helper"

class Edition::Details::Fields::VideoRelayServiceComponentTest < BaseComponentTestClass
  let(:described_class) { Edition::Details::Fields::VideoRelayServiceComponent }

  let(:edition) { build(:edition, :contact) }

  let(:properties) do
    {
      "video_relay_service" => {
        "type" => "object",
        "properties" => {
          "show" => {
            "type" => "boolean", "default" => false
          },
          "label" => {
            "type" => "string", "default" => "Text relay: dial 18001 then:"
          },
          "telephone_number" => {
            "type" => "string", "default" => "0800 123 4567"
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

  let(:subschema) do
    Schema::EmbeddedSchema.new(
      "telephones",
      body,
      "parent_schema_id",
    )
  end

  let(:field) do
    Schema::Field.new(
      "video_relay_service",
      subschema,
    )
  end

  let(:field_value) do
    {
      "show" => nil,
      "label" => nil,
      "telephone_number" => nil,
    }
  end

  let(:schema) { stub(:schema, block_type: "schema") }

  let(:component) do
    described_class.new(
      edition:,
      field: field,
      value: field_value,
      schema:,
      subschema: subschema,
    )
  end

  before do
    Edition::Details::Fields::TextareaComponent.any_instance.stubs(:helpers).returns(helper_stub)
  end

  describe "VideoRelayService component" do
    describe "'show' nested field" do
      it "shows a checkbox to toggle 'show' option" do
        helper_stub.stubs(:humanized_label).returns("Add text relay")

        render_inline(component)

        assert_selector(".app-c-content-block-manager-video-relay-service-component") do |component|
          component.assert_selector("label", text: "Add text relay")
        end
      end

      context "when the 'show' value is 'true'" do
        let(:field_value) do
          {
            "show" => true,
            "label" => nil,
            "telephone_number" => nil,
          }
        end

        it "sets the checkbox to _checked_" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-video-relay-service-component") do |component|
            component.assert_selector("input[checked='checked']")
          end
        end
      end

      context "when the 'show' value is 'false'" do
        let(:field_value) do
          {
            "show" => false,
            "label" => nil,
            "telephone_number" => nil,
          }
        end

        it "sets the checkbox to _unchecked_" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-video-relay-service-component") do |component|
            component.assert_no_selector("input[checked='checked']")
          end
        end
      end

      context "when the 'show' field has related hint text" do
        it "shows the hint text" do
          component.stubs(:hint_text).returns({ show: "Some hint text" })

          render_inline(component)

          assert_selector(".app-c-content-block-manager-video-relay-service-component") do |component|
            component.assert_selector(".govuk-checkboxes__item .govuk-hint", text: "Some hint text")
          end
        end
      end

      context "when the 'show' does not have related hint text" do
        it "shows the hint text" do
          component.stubs(:hint_text).returns(nil)

          render_inline(component)

          assert_selector(".app-c-content-block-manager-video-relay-service-component") do |component|
            component.assert_no_selector(".govuk-checkboxes__item .govuk-hint")
          end
        end
      end
    end

    describe "'label' nested field" do
      context "when a value is set for the 'label'" do
        let(:field_value) do
          {
            "show" => nil,
            "label" => "Custom label: 19222 then",
            "telephone_number" => nil,
          }
        end

        it "displays that value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-video-relay-service-component") do |component|
            component.assert_selector(
              "input" \
              "[name='edition[details][telephones][video_relay_service][label]']" \
              "[value='Custom label: 19222 then']",
            )
          end
        end
      end

      context "when a value is NOT set for the 'telephone_number_label'" do
        let(:field_value) do
          {
            "show" => nil,
            "label" => nil,
            "telephone_number" => nil,
          }
        end

        it "displays the default value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-video-relay-service-component") do |component|
            component.assert_selector(
              "input" \
              "[name='edition[details][telephones][video_relay_service][label]']" \
              "[value='Text relay: dial 18001 then:']",
            )
          end
        end
      end
    end

    describe "'telephone_number' nested field" do
      context "when a value is set for the 'telephone_number'" do
        let(:field_value) do
          {
            "show" => nil,
            "label" => nil,
            "telephone_number" => "1234 987 6543",
          }
        end

        it "displays that value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-video-relay-service-component") do |component|
            component.assert_selector(
              "input" \
              "[name='edition[details][telephones][video_relay_service][telephone_number]']" \
              "[value='1234 987 6543']",
            )
          end
        end
      end

      context "when a value is NOT set for the 'telephone_number'" do
        let(:field_value) do
          {
            "show" => nil,
            "label" => nil,
            "telephone_number" => nil,
          }
        end

        it "displays the default value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-video-relay-service-component") do |component|
            component.assert_selector(
              "input" \
              "[name='edition[details][telephones][video_relay_service][telephone_number]']" \
              "[value='0800 123 4567']",
            )
          end
        end
      end
    end
  end

  describe "when errors are present" do
    before do
      edition.errors.add(:details_telephones_video_relay_service_label, "Label error")
      edition.errors.add(:details_telephones_video_relay_service_telephone_number, "Telephone error")
    end

    it "should show errors" do
      helper_stub.stubs(:humanized_label).with(schema_name: "schema", relative_key: "label", root_object: "telephones.video_relay_service").returns("Label")
      helper_stub.stubs(:humanized_label).with(schema_name: "schema", relative_key: "telephone_number", root_object: "telephones.video_relay_service").returns("Telephone number")

      render_inline(component)

      assert_selector ".govuk-form-group.govuk-form-group--error", text: /Label/ do |form_group|
        form_group.assert_selector ".govuk-error-message", text: "Label error"
        form_group.assert_selector "input.govuk-input--error"
      end

      assert_selector ".govuk-form-group.govuk-form-group--error", text: /Telephone number/ do |form_group|
        form_group.assert_selector ".govuk-error-message", text: "Telephone error"
        form_group.assert_selector "input.govuk-input--error"
      end
    end
  end
end
