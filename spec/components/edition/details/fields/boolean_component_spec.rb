RSpec.describe Edition::Details::Fields::BooleanComponent, type: :component do
  let(:described_class) { Edition::Details::Fields::BooleanComponent }

  let(:edition) { build(:edition, :pension) }
  let(:field) { double("field", name: "email_address", is_required?: true) }
  let(:schema) { double(:schema, block_type: "schema") }

  before do
    render_inline(
      described_class.new(
        edition:,
        field:,
        schema:,
        value: field_value,
      ),
    )
  end

  describe "when no value is given" do
    let(:field_value) { nil }

    it "should not check the checkbox" do
      expect(page).to have_css "input[type=\"checkbox\"][value=\"true\"]"
      expect(page).to_not have_css "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
    end
  end

  describe "when the value given is 'true'" do
    let(:field_value) { "true" }

    it "should check the checkbox" do
      expect(page).to have_css "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
    end
  end

  describe "when the value given is 'false'" do
    let(:field_value) { "false" }

    it "should check the checkbox" do
      expect(page).to_not have_css "input[type=\"checkbox\"][value=\"true\"][checked=\"checked\"]"
    end
  end
end
