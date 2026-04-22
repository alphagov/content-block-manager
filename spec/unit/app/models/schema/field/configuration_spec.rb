RSpec.describe Schema::Field::Configuration do
  let(:schema) { build(:schema) }
  let(:field) { Schema::Field.new("something", schema) }

  let(:body) { {} }

  before do
    allow(schema).to receive(:body).and_return(body)
  end

  describe "#hidden?" do
    describe "when the body includes an `x-hidden-field` property" do
      let(:body) do
        { "properties" => { "something" => { "type" => "boolean", "x-hidden-field" => true } } }
      end

      it "returns true" do
        expect(field.hidden?).to be_truthy
      end
    end

    describe "when the body does not include an `x-hidden-field` property" do
      it "returns false" do
        expect(field.hidden?).to be_falsey
      end
    end
  end

  describe "#govspeak_enabled?" do
    context "when the body includes an `x-govspeak-enabled` property" do
      let(:body) do
        { "properties" => { "something" => { "type" => "string", "x-govspeak-enabled" => true } } }
      end

      it "returns true" do
        expect(field.govspeak_enabled?).to be_truthy
      end
    end

    context "when the body does not include an `x-govspeak-enabled` property" do
      it "returns false" do
        expect(field.govspeak_enabled?).to be_falsey
      end
    end
  end

  describe "#character_limit" do
    context "when the body includes a `x-character-limit` property" do
      let(:body) do
        { "properties" => { "something" => { "type" => "string", "x-character-limit" => 123 } } }
      end

      it "returns a character limit" do
        expect(field.character_limit).to eq(123)
      end
    end

    context "when the body does not include a `x-character-limit` property" do
      it "returns a character limit" do
        expect(field.character_limit).to be_nil
      end
    end
  end

  describe "#show_field" do
    let(:body) do
      {
        "properties" => {
          "something" => {
            "type" => "object",
            "properties" => {
              "show_field" => { "type" => "boolean" },
              "text" => { "type" => "string" },
            },
          },
        },
      }
    end

    context "when the field does not have an x-show-field-name property in the schema body" do
      it "returns nil" do
        show_field = field.show_field

        expect(show_field).to be_nil
      end
    end

    context "when the field has an x-show-field-name property in the schema body" do
      let(:body) do
        {
          "properties" => {
            "something" => {
              "type" => "object",
              "x-show-field-name" => "show_field",
              "properties" => {
                "show_field" => { "type" => "boolean" },
                "text" => { "type" => "string" },
              },
            },
          },
        }
      end

      it "returns the field to conditionally reveal an object" do
        show_field = field.show_field

        expect(show_field).to_not be_nil
        expect(show_field.name).to eq("show_field")
      end
    end
  end

  describe "#component_name" do
    describe "when there is no custom component set" do
      describe "when the field is a string" do
        let(:body) do
          { "properties" => { "something" => { "type" => "string" } } }
        end

        it "returns string" do
          expect(field.component_name).to eq("string")
        end
      end

      describe "when the field has enum values" do
        let(:body) do
          { "properties" => { "something" => { "type" => "string", "enum" => %w[foo bar] } } }
        end

        it "returns enum" do
          expect(field.component_name).to eq("enum")
        end
      end
    end

    describe "when there is a custom component set" do
      let(:body) do
        { "properties" => { "something" => { "type" => "string", "x-component-name" => "custom" } } }
      end

      it "returns the custom component name" do
        expect(field.component_name).to eq("custom")
      end
    end

    describe "when the field is an object" do
      let(:body) do
        { "properties" => { "something" => { "type" => "object" } } }
      end

      it "returns object" do
        expect(field.component_name).to eq("object")
      end
    end
  end
end
