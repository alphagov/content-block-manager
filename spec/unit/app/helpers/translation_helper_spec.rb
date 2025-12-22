RSpec.describe TranslationHelper do
  include TranslationHelper

  describe "translated_value" do
    it "calls translation config with value" do
      allow(I18n).to receive(:t)
          .with("edition.values.key.field value", default: ["edition.values.field value".to_sym, "field value"])
          .and_return("field value")

      expect(translated_value("key", "field value")).to eq("field value")
    end
  end

  describe "#label_for_title" do
    let(:block_type) { "something" }
    let(:default_title) { "Default title" }
    let(:alternative_title) { "Alternative title" }

    before do
      allow(I18n).to receive(:t).with("activerecord.attributes.edition/document.title.default")
          .and_return(default_title)
    end

    it "returns an alternative label for the block type if it exists" do
      allow(I18n).to receive(:t).with("activerecord.attributes.edition/document.title.#{block_type}", default: nil)
          .and_return(alternative_title)

      expect(label_for_title(block_type)).to eq(alternative_title)
    end

    it "returns the default for the block type if it does not exist" do
      allow(I18n).to receive(:t).with("activerecord.attributes.edition/document.title.#{block_type}", default: nil)
          .and_return(nil)

      expect(label_for_title(block_type)).to eq(default_title)
    end
  end
end
