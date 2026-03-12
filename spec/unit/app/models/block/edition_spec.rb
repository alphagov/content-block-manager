RSpec.describe Block::Edition, type: :model do
  # Since Edition is abstract, we need a concrete subclass for testing
  let(:concrete_edition_class) do
    Class.new(Block::Edition) do
      def self.name
        "Block::OtherTypeEdition"
      end

      def details
        { "field_1" => "value 1" }
      end
    end
  end

  # Another concrete subclass, this one missing the #details implementation
  let(:edition_class_missing_implementation) do
    Class.new(Block::Edition) do
      def self.name
        "Block::MissingImplementationEdition"
      end
    end
  end

  describe "associations" do
    subject { concrete_edition_class.new(title: "Other Type Title") }
    it { is_expected.to belong_to(:document).class_name("Block::Document") }
  end

  describe "validations" do
    subject { concrete_edition_class.new(title: "Other Type Title") }

    it { is_expected.to validate_presence_of(:title) }
  end

  describe "#details" do
    it "raises NotImplementedError when called on class with no #details method" do
      expect { edition_class_missing_implementation.new.details }.to raise_error(
        NotImplementedError, "Subclasses must implement #details method"
      )
    end

    it "can be implemented by subclasses" do
      document = Block::Document.create!(sluggable_string: "other-type-block", block_type: "time_period")
      edition = concrete_edition_class.new(
        document: document,
        title: "Other Type Title",
      )
      expect(edition.details).to eq({ "field_1" => "value 1" })
    end
  end
end
