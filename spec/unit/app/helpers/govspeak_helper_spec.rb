RSpec.describe GovspeakHelper, type: :helper do
  describe "render_govspeak_if_enabled_for_field(object_key:, field_name:, value:)" do
    let(:field) { double(:field, govspeak_enabled?: govspeak_enabled) }
    let(:subschema) { double(:subschema) }

    before do
      allow(subschema).to receive(:field).with("field_1").and_return(field)
    end

    context "when the field has been declared govspeak_enabled" do
      let(:govspeak_enabled) { true }

      it "renders the given value into HTML using the GovSpeak gem" do
        html = render_govspeak_if_enabled_for_field(field_name: "field_1", value: "value")
        expect(html.strip).to eq("<p>value</p>")
      end
    end

    context "when the field has NOT been declared govspeak_enabled" do
      let(:govspeak_enabled) { false }

      it "renders the given value without converting to HTML" do
        html = render_govspeak_if_enabled_for_field(field_name: "field_1", value: "value")
        expect(html.strip).to eq("value")
      end
    end
  end
end
