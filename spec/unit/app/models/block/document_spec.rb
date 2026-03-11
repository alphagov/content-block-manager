RSpec.describe Block::Document, type: :model do
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
      it "generates embed_code before validation on create" do
        document = described_class.new(
          sluggable_string: "test-block",
          block_type: "time_period",
        )
        expect(document.embed_code).to be_nil
        document.valid?
        expect(document.embed_code).to be_present
        expect(document.embed_code).to eq(document.built_embed_code)
      end

      it "does not override an existing embed_code" do
        custom_code = "{{custom_code}}"
        document = described_class.new(
          embed_code: custom_code,
          sluggable_string: "test-block",
          block_type: "time_period",
        )
        document.valid?
        expect(document.embed_code).to eq(custom_code)
      end
    end
  end

  describe "#built_embed_code" do
    it "returns the embed code format for the block" do
      document = described_class.new(
        content_id: "12345678-1234-1234-1234-123456789abc",
        block_type: "time_period",
      )
      expected = "{{embed:content_block:time_period:" \
                 "12345678-1234-1234-1234-123456789abc}}"
      expect(document.built_embed_code).to eq(expected)
    end
  end

  describe "#embed_code_for_field" do
    it "returns the embed code format for a specific field" do
      document = described_class.new(
        content_id: "12345678-1234-1234-1234-123456789abc",
        block_type: "time_period",
      )
      expected = "{{embed:content_block:time_period:" \
                 "12345678-1234-1234-1234-123456789abc:" \
                 "date_range/start/date}}"
      expect(document.embed_code_for_field("date_range/start/date"))
        .to eq(expected)
    end
  end
end
