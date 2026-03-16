RSpec.describe "components/datetime_fields", type: :view do
  def render_component(locals)
    render partial: "components/datetime_fields", locals:
  end

  it "renders nothing without prefix and field_name" do
    render_component({})

    expect(rendered).to be_blank
  end

  it "renders nothing with only a prefix" do
    render_component({ prefix: "my_prefix", id: "my-id" })

    expect(rendered).to be_blank
  end

  it "renders nothing with only a field_name" do
    render_component({ field_name: "my_field", id: "my-id" })

    expect(rendered).to be_blank
  end

  context "when prefix and field_name are provided" do
    let(:defaults) do
      { prefix: "my_prefix", field_name: "my_field", id: "my-id" }
    end

    it "renders the root wrapper with the correct classes" do
      render_component(defaults)

      expect(rendered).to have_css ".app-c-datetime-fields.govuk-form-group"
    end

    describe "time fields" do
      it "renders the time fieldset with Hour and Minute selects by default" do
        render_component(defaults)

        expect(rendered).to have_css "legend", text: "Time"
        expect(rendered).to have_css "label", text: "Hour"
        expect(rendered).to have_css "label", text: "Minute"
        expect(rendered).to have_css "select.govuk-select.app-c-datetime-fields__date-time-input", count: 2
      end

      it "renders the time separator" do
        render_component(defaults)

        expect(rendered).to have_css "p.govuk-body.app-c-datetime-fields__time-separator", text: ":"
      end

      it "does not render the time section when date_only is true" do
        render_component(defaults.merge(date_only: true))

        expect(rendered).not_to have_css "legend", text: "Time"
        expect(rendered).not_to have_css "label", text: "Hour"
        expect(rendered).not_to have_css "label", text: "Minute"
      end

      it "renders the time hint when provided" do
        render_component(defaults.merge(time_hint: "Use 24-hour format"))

        expect(rendered).to have_css ".govuk-hint", text: "Use 24-hour format"
      end

      it "does not render a time hint when not provided" do
        render_component(defaults)

        expect(rendered).not_to have_css ".govuk-hint"
      end

      it "uses the field_name with (4i) suffix for the hour select" do
        render_component(defaults)

        expect(rendered).to have_css "select[name='my_prefix[my_field(4i)]']"
      end

      it "uses the field_name with (5i) suffix for the minute select" do
        render_component(defaults)

        expect(rendered).to have_css "select[name='my_prefix[my_field(5i)]']"
      end

      it "pre-selects the hour value when provided" do
        render_component(defaults.merge(hour: { value: 10 }))

        expect(rendered).to have_css "select[name='my_prefix[my_field(4i)]'] option[value='10'][selected]"
      end

      it "pre-selects the minute value when provided" do
        render_component(defaults.merge(minute: { value: 30 }))

        expect(rendered).to have_css "select[name='my_prefix[my_field(5i)]'] option[value='30'][selected]"
      end

      context "when hour[:name] is provided" do
        it "uses it as the select name without a prefix" do
          render_component(defaults.merge(hour: { name: "my_field(4i)" }))

          expect(rendered).to have_css "select[name='my_field(4i)']"
        end
      end

      context "when minute[:name] is provided" do
        it "uses it as the select name without a prefix" do
          render_component(defaults.merge(minute: { name: "my_field(5i)" }))

          expect(rendered).to have_css "select[name='my_field(5i)']"
        end
      end
    end

    describe "date fields" do
      it "renders the date fieldset with the default heading" do
        render_component(defaults)

        expect(rendered).to have_css "legend", text: "Date (required)"
      end

      it "uses a custom date heading when provided" do
        render_component(defaults.merge(date_heading: "Publication date"))

        expect(rendered).to have_css "legend", text: "Publication date"
        expect(rendered).not_to have_css "legend", text: "Date (required)"
      end
    end

    describe "error messages" do
      it "adds the error class when error_items are present" do
        render_component(defaults.merge(error_items: [{ text: "Enter a date" }]))

        expect(rendered).to have_css ".govuk-form-group.govuk-form-group--error"
      end

      it "does not add the error class when error_items are absent" do
        render_component(defaults)

        expect(rendered).not_to have_css ".govuk-form-group--error"
      end
    end

    it "passes data attributes to the root wrapper" do
      render_component(defaults.merge(data_attributes: { module: "my-module" }))

      expect(rendered).to have_css ".app-c-datetime-fields[data-module='my-module']"
    end
  end
end
