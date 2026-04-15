RSpec.describe Block::Document, type: :model do
  describe "associations" do
    describe "#time_period_editions" do
      it "builds a TimePeriodEdition with the correct type" do
        document = build(:block_document, block_type: "time_period")
        edition = document.time_period_editions.build(title: "Test")

        expect(edition).to be_a(Block::TimePeriodEdition)
        expect(edition.type).to eq("Block::TimePeriodEdition")
      end

      it "only returns TimePeriodEdition instances" do
        document = create(:block_document, block_type: "time_period")
        time_period = create(:time_period_edition, document: document)
        other = create(:other_edition, document: document)

        expect(document.editions.count).to eq(2)
        expect(document.time_period_editions.count).to eq(1)
        expect(document.time_period_editions.first).to eq(time_period)
        expect(document.time_period_editions).not_to include(other)
      end
    end
  end

  describe "callbacks" do
    describe "generate_content_id" do
      it "generates a UUID for content_id before validation on create" do
        document = described_class.new(
          sluggable_string: "test-block",
          block_type: "time_period",
        )
        expect(document.content_id).to be_nil
        document.valid?
        expect(document.content_id).to be_present
        uuid_pattern = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-/
        expect(document.content_id)
          .to match(/#{uuid_pattern}[0-9a-f]{4}-[0-9a-f]{12}\z/)
      end

      it "does not override an existing content_id" do
        custom_uuid = SecureRandom.uuid
        document = described_class.new(
          content_id: custom_uuid,
          sluggable_string: "test-block",
          block_type: "time_period",
        )
        document.valid?
        expect(document.content_id).to eq(custom_uuid)
      end
    end

    describe "generate_embed_code" do
      it "generates embed_code after validation on create using content_id_alias" do
        document = described_class.new(
          sluggable_string: "test-block",
          block_type: "time_period",
        )
        expect(document.embed_code).to be_nil
        document.valid?
        expect(document.embed_code).to be_present
        expect(document.embed_code).to eq("{{embed:content_block_time_period:test-block}}")
      end
    end
  end

  describe "#built_embed_code" do
    it "returns the embed code format using content_id_alias" do
      document = described_class.new(
        sluggable_string: "current-tax-year",
        block_type: "time_period",
      )
      document.valid? # triggers FriendlyId to set content_id_alias
      expect(document.built_embed_code).to eq("{{embed:content_block_time_period:current-tax-year}}")
    end
  end

  describe "#embed_code_for_field" do
    it "returns the embed code format for a specific field using content_id_alias" do
      document = described_class.new(
        sluggable_string: "current-tax-year",
        block_type: "time_period",
      )
      document.valid? # triggers FriendlyId to set content_id_alias
      expect(document.embed_code_for_field("date_range/start/date"))
        .to eq("{{embed:content_block_time_period:current-tax-year/date_range/start/date}}")
    end
  end

  describe "#title" do
    it "returns the title from the most recent edition" do
      document = create(:block_document, block_type: "time_period")
      create(:time_period_edition, document: document, title: "First Edition", created_at: 1.day.ago)
      create(:time_period_edition, document: document, title: "Latest Edition", created_at: Time.current)

      expect(document.title).to eq("Latest Edition")
    end

    it "returns nil when there are no editions" do
      document = create(:block_document, block_type: "time_period")

      expect(document.title).to be_nil
    end
  end
end
