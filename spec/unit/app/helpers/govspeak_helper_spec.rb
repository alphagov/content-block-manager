RSpec.describe GovspeakHelper, type: :helper do
  describe "render_govspeak_if_enabled_for_field(object_key:, field_name:, value:)" do
    let(:subschema) { double(:subschema) }

    context "when the field has been declared 'govspeak_enabled' in the schema" do
      before do
        allow(subschema).to receive(:govspeak_enabled?).and_return(true)
      end

      it "renders the given value into HTML using the GovSpeak gem" do
        html = render_govspeak_if_enabled_for_field(object_key: "nested_obj", field_name: "field_1", value: "value")
        expect(html.strip).to eq("<p>value</p>")
      end
    end

    context "when the field has NOT been declared 'govspeak_enabled' in the schema" do
      before do
        allow(subschema).to receive(:govspeak_enabled?).and_return(false)
      end

      it "renders the given value without converting to HTML" do
        html = render_govspeak_if_enabled_for_field(object_key: "nested_obj", field_name: "field_1", value: "value")
        expect(html.strip).to eq("value")
      end
    end
  end
end
