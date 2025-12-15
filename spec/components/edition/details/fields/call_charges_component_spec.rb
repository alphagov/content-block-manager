RSpec.describe Edition::Details::Fields::CallChargesComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::CallChargesComponent }

  let(:edition) { build(:edition, :contact) }
  let(:helper_stub) { double(:helpers) }

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

  let(:schema) { double(:schema, block_type: "schema", body:, id: "schema_id") }

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

  before do
    allow(component).to receive(:helpers).and_return(helper_stub)
    allow(helper_stub).to receive(:hint_text).and_return({ show_call_charges_info_url: "Hint text" })
    allow(helper_stub).to receive(:humanized_label).and_return("Translated label")
  end

  describe "Call Charges component" do
    describe "'show_call_charges_info_url' nested field" do
      it "shows a checkbox to toggle 'Show hyperlink' option" do
        allow(helper_stub).to receive(:humanized_label).and_return("Show hyperlink to 'Find out about call charges'")

        render_inline(component)

        expect(page).to have_css(".app-c-content-block-manager-call-charges-component") do |component|
          expect(component).to have_css("label", text: "Show hyperlink to 'Find out about call charges'")
          expect(component).to have_css("input[type='checkbox']", count: 1)
          expect(component).to have_css(".govuk-hint", text: "Hint text")
        end
      end

      context "when the 'show_call_charges_info_url' value is true" do
        let(:field_value) do
          { "call_charges_info_url" => nil,
            "show_call_charges_info_url" => true }
        end

        it "sets the checkbox to _checked_" do
          render_inline(component)

          expect(page).to have_css(".app-c-content-block-manager-call-charges-component") do |component|
            expect(component).to have_css("input[checked='checked']")
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

          expect(page).to have_css(".app-c-content-block-manager-call-charges-component") do |component|
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

          expect(page).to have_css(".app-c-content-block-manager-call-charges-component") do |component|
            expect(component).to have_css(
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

          expect(page).to have_css(".app-c-content-block-manager-call-charges-component") do |component|
            expect(component).to have_css(
              "input" \
              "[name='edition[details][call_charges][call_charges_info_url]']" \
              "[value='https://default.example.com']",
            )
          end
        end
      end
    end

    describe "when call charges errors are present" do
      it "should show errors when present" do
        edition.errors.add(:details_call_charges_label, "Some label is required")
        edition.errors.add(:details_call_charges_call_charges_info_url, "Some URL is required")

        render_inline(component)

        expect(page).to have_css ".govuk-form-group--error", count: 2
        expect(page).to have_css "input.govuk-input--error", count: 2

        expect(page).to have_css ".govuk-error-message", text: "Some label is required"
        expect(page).to have_css ".govuk-error-message", text: "Some URL is required"
      end
    end
  end
end
