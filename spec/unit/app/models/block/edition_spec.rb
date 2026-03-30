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

    let(:document) { Block::Document.create!(sluggable_string: "test-block", block_type: "time_period") }

    it { is_expected.to validate_presence_of(:title) }

    describe "title alphanumeric validation" do
      it "is valid when title contains letters" do
        edition = concrete_edition_class.new(title: "Valid Title", lead_organisation_id: SecureRandom.uuid, document:)
        expect(edition).to be_valid
      end

      it "is valid when title contains numbers" do
        edition = concrete_edition_class.new(title: "2024", lead_organisation_id: SecureRandom.uuid, document:)
        expect(edition).to be_valid
      end

      it "is invalid when title contains only special characters" do
        edition = concrete_edition_class.new(title: "---", lead_organisation_id: SecureRandom.uuid, document:)
        edition.valid?
        expect(edition.errors[:title]).to include("must contain at least one letter or number")
      end
    end

    describe "lead_organisation_id presence validation" do
      it "is invalid when lead_organisation_id is blank" do
        edition = concrete_edition_class.new(title: "Valid Title", lead_organisation_id: nil, document:)
        edition.valid?
        expect(edition.errors[:lead_organisation_id]).to include("cannot be blank")
      end

      it "is valid when lead_organisation_id is present" do
        edition = concrete_edition_class.new(title: "Valid Title", lead_organisation_id: SecureRandom.uuid, document:)
        expect(edition).to be_valid
      end
    end
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
