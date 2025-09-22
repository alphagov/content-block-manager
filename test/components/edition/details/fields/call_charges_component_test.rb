require "test_helper"

class Edition::Details::Fields::CallChargesComponentTest < BaseComponentTestClass
  let(:described_class) { Edition::Details::Fields::CallChargesComponent }

  let(:edition) { build(:edition, :contact) }

  let(:body) do
    {
      "type" => "object",
      "properties" =>
        { "call_charges" =>
          { "type" => "object",
            "properties" =>
          { "label" => { "type" => "string", "default" => "Find out about call charges" },
            "call_charges_info_url" => { "type" => "string", "default" => "https://default.example.com" },
            "show_call_charges_info_url" => { "type" => "boolean", "default" => false } } } },
    }
  end

  let(:schema) { stub(:schema, block_type: "schema", body:) }

  let(:field) do
    Schema::Field.new(
      "call_charges",
      schema,
    )
  end

  let(:field_value) do
    { "call_charges_info_url" => nil,
      "show_call_charges_info_url" => nil }
  end

  let(:component) do
    described_class.new(
      edition:,
      field: field,
      schema:,
      value: field_value,
    )
  end

  describe "Call Charges component" do
    describe "'show_call_charges_info_url' nested field" do
      it "shows a checkbox to toggle 'Show hyperlink' option" do
        helper_stub.stubs(:humanized_label).returns("Show hyperlink to 'Find out about call charges'")

        render_inline(component)

        assert_selector(".app-c-content-block-manager-call-charges-component") do |component|
          component.assert_selector("label", text: "Show hyperlink to 'Find out about call charges'")
        end
      end

      context "when the 'show_call_charges_info_url' value is true" do
        let(:field_value) do
          { "call_charges_info_url" => nil,
            "show_call_charges_info_url" => true }
        end

        it "sets the checkbox to _checked_" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-call-charges-component") do |component|
            component.assert_selector("input[checked='checked']")
          end
        end
      end

      context "when the 'show_call_charges_info_url' value is false" do
        let(:field_value) do
          { "call_charges_info_url" => nil,
            "show_call_charges_info_url" => false }
        end

        it "sets the checkbox to _unchecked_" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-call-charges-component") do |component|
            component.assert_no_selector("input[checked='checked']")
          end
        end
      end
    end

    describe "'call_charges_info_url' nested field" do
      context "when a value is set for the 'call_charges_info_url'" do
        let(:field_value) do
          { "call_charges_info_url" => "https://custom.gov.uk/call-charges/more",
            "show_call_charges_info_url" => nil }
        end

        it "displays that value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-call-charges-component") do |component|
            component.assert_selector(
              "input" \
              "[name='edition[details][call_charges][call_charges_info_url]']" \
              "[value='https://custom.gov.uk/call-charges/more']",
            )
          end
        end
      end

      context "when a value is NOT set for the 'call_charges_info_url'" do
        let(:field_value) do
          { "call_charges_info_url" => nil,
            "show_call_charges_info_url" => nil }
        end

        it "displays the default value in the input field" do
          render_inline(component)

          assert_selector(".app-c-content-block-manager-call-charges-component") do |component|
            component.assert_selector(
              "input" \
              "[name='edition[details][call_charges][call_charges_info_url]']" \
              "[value='https://default.example.com']",
            )
          end
        end
      end
    end
  end
end
