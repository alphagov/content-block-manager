require "test_helper"

class Edition::Details::Fields::VideoRelayServiceComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:edition) { build(:edition, :contact) }

  let(:properties) do
    {
      "video_relay_service" => {
        "type" => "object",
        "properties" => {
          "show" => {
            "type" => "boolean", "default" => false
          },
          "prefix" => {
            "type" => "string", "default" => "**Default** prefix: 18000 then"
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
      "prefix" => nil,
      "telephone_number" => nil,
    }
  end

  let(:schema) { stub(:schema) }

  let(:component) do
    Edition::Details::Fields::VideoRelayServiceComponent.new(
      edition:,
      field: field,
      value: field_value,
      schema:,
      subschema: subschema,
    )
  end

  describe "VideoRelayService component" do
    describe "'show' nested field" do
      it "shows a checkbox to toggle 'show' option" do
        render_inline(component)

        assert_selector(".app-c-content-block-manager-video-relay-service-component") do |component|
          component.assert_selector("label", text: I18n.t("edition.details.labels.telephones.video_relay_service.show"))
        end
      end

      context "when the 'show' value is 'true'" do
        let(:field_value) do
          {
            "show" => true,
            "prefix" => nil,
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
            "prefix" => nil,
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
    end

    describe "'prefix' nested field" do
      context "when a value is set for the 'prefix'" do
        let(:field_value) do
          {
            "show" => nil,
            "prefix" => "**Custom** prefix: 19222 then",
            "telephone_number" => nil,
          }
        end

        it "displays that value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-video-relay-service-component") do |component|
            component.assert_selector(
              "textarea" \
              "[name='edition[details][telephones][video_relay_service][prefix]']",
              text: "**Custom** prefix: 19222 then",
            )
          end
        end
      end

      context "when a value is NOT set for the 'telephone_number_prefix'" do
        let(:field_value) do
          {
            "show" => nil,
            "prefix" => nil,
            "telephone_number" => nil,
          }
        end

        it "displays the default value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-video-relay-service-component") do |component|
            component.assert_selector(
              "textarea" \
              "[name='edition[details][telephones][video_relay_service][prefix]']",
              text: "**Default** prefix: 18000 then",
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
            "prefix" => nil,
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
            "prefix" => nil,
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
      edition.errors.add(:details_telephones_video_relay_service_prefix, "Prefix error")
      edition.errors.add(:details_telephones_video_relay_service_telephone_number, "Telephone error")
    end

    it "should show errors" do
      render_inline(component)

      assert_selector ".govuk-form-group.govuk-form-group--error", text: /Prefix/ do |form_group|
        form_group.assert_selector ".govuk-error-message", text: "Prefix error"
        form_group.assert_selector "textarea.govuk-textarea--error"
      end

      assert_selector ".govuk-form-group.govuk-form-group--error", text: /Telephone number/ do |form_group|
        form_group.assert_selector ".govuk-error-message", text: "Telephone error"
        form_group.assert_selector "input.govuk-input--error"
      end
    end
  end
end
