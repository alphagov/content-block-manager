RSpec.shared_examples "a field component" do |field_type:, value: "example@example.com"|
  let(:field_type) { field_type }

  it "renders a #{field_type}" do
    render_inline component

    expect(page).to have_css("label", text: field.label)
    expect(page).to have_css("#{field_type}[name=\"#{context.name}\"][id=\"#{context.id}\"]")
  end

  context "when the field is optional" do
    before do
      allow(field).to receive(:is_required?).and_return(false)
    end

    it "should show optional label when field is optional" do
      render_inline component

      expect(page).to have_css "label", text: "#{field.label} (optional)"
    end
  end

  context "when hint text is present" do
    before do
      expect(context).to receive(:hint_text).and_return("Some hint text")
    end

    it "should render hint text" do
      render_inline component

      expect(page).to have_css ".govuk-hint", text: "Some hint text"
    end
  end

  context "when errors are present" do
    before do
      expect(context).to receive(:error_items).and_return([{
        text: "Some error goes here",
      }])
    end

    it "should show errors" do
      render_inline component

      expect(page).to have_css ".govuk-form-group--error"
      expect(page).to have_css ".govuk-error-message", text: "Some error goes here"
      expect(page).to have_css "#{field_type}.govuk-#{field_type}--error"
    end
  end

  context "when a value is present" do
    context "when the value is provided" do
      let(:value) { value }

      before do
        allow(context).to receive(:value).and_return(value)
      end

      it "should show the value" do
        render_inline component

        field = page.find("#{field_type}[name=\"#{context.name}\"][id=\"#{context.id}\"]")
        expect(field.value).to eq(value)
      end
    end
  end
end
