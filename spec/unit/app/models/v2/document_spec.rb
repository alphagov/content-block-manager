RSpec.describe V2::Document, type: :model do
  let(:v2_edition_with_details) do
    Class.new(V2::Edition) do
      def self.name
        "V2::FooEdition"
      end

      def lead_organisation_id
        SecureRandom.uuid
      end
    end
  end

  let(:creator) { create(:user) }

  describe "associations" do
    describe "#time_period_editions" do
      it "builds a TimePeriodEdition with the correct type" do
        document = build(:v2_document, block_type: "time_period")
        edition = document.time_period_editions.build(title: "Test")

        expect(edition).to be_a(V2::TimePeriodEdition)
        expect(edition.type).to eq("V2::TimePeriodEdition")
      end

      it "only returns TimePeriodEdition instances" do
        document = create(:v2_document, block_type: "time_period")
        time_period = create(:v2_time_period_edition, document: document, creator:)
        other = v2_edition_with_details.new(document: document, title: "Foo Edition", creator:).save!

        expect(document.editions.count).to eq(2)
        expect(document.time_period_editions.count).to eq(1)
        expect(document.time_period_editions.first).to eq(time_period)
        expect(document.time_period_editions).not_to include(other)
      end
    end

    describe "#most_recent_edition" do
      it "returns the most recently created edition" do
        document = create(:v2_document, block_type: "time_period")

        _older_edition = create(:v2_time_period_edition, document: document, created_at: 2.days.ago)
        newer_edition = create(:v2_time_period_edition, document: document, created_at: 1.day.ago)
        _oldest_edition = create(:v2_time_period_edition, document: document, created_at: 3.days.ago)

        expect(document.most_recent_edition).to eq(newer_edition)
      end

      it "returns nil when there are no editions" do
        document = create(:v2_document, block_type: "time_period")

        expect(document.most_recent_edition).to be_nil
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

  describe ".by_most_recently_created_edition" do
    it "orders documents so the document with the most recently created edition appears first" do
      older_document_with_newer_edition = create(:v2_document, created_at: 4.days.ago)
      create(:v2_time_period_edition, document: older_document_with_newer_edition, created_at: 4.days.ago)
      create(:v2_time_period_edition, document: older_document_with_newer_edition, created_at: 1.day.ago)

      newer_document_with_older_edition = create(:v2_document, created_at: 3.days.ago)
      create(:v2_time_period_edition, document: newer_document_with_older_edition, created_at: 3.days.ago)
      create(:v2_time_period_edition, document: newer_document_with_older_edition, created_at: 2.days.ago)

      expect(described_class.by_most_recently_created_edition).to eq([older_document_with_newer_edition, newer_document_with_older_edition])
    end
  end

  describe ".where_block_type" do
    subject(:scope) { described_class.where_block_type(filter) }

    let!(:time_period_doc) { create(:v2_document, block_type: :time_period) }

    context "when filtering with matching criteria" do
      context "with a string key" do
        let(:filter) { "time_period" }

        it "returns matching documents" do
          expect(scope).to contain_exactly(time_period_doc)
        end
      end

      context "with an array of values" do
        let(:filter) { %w[time_period non_matching_type] }

        it "filters accurately by the array contents" do
          expect(scope).to contain_exactly(time_period_doc)
        end
      end
    end

    context "when filtering with non-matching criteria" do
      let(:filter) { "non_matching_type" }

      it "returns an empty array" do
        expect(scope).to eq([])
      end
    end

    context "when argument is blank" do
      [nil, "", []].each do |blank_value|
        context "when filter is #{blank_value.inspect}" do
          let(:filter) { blank_value }

          it "returns all records as an ActiveRecord relation" do
            expect(scope).to contain_exactly(time_period_doc)
            expect(scope).to be_a(ActiveRecord::Relation)
          end
        end
      end
    end
  end

  describe ".where_lead_organisation" do
    subject(:scope) { described_class.where_lead_organisation(org_id) }

    let(:target_org_id) { SecureRandom.uuid }
    let(:other_org_id) { SecureRandom.uuid }

    let!(:matching_doc) { create(:v2_document) }
    let!(:non_matching_doc) { create(:v2_document) }

    before do
      create(:v2_time_period_edition, document: matching_doc, lead_organisation_id: target_org_id)
      create(:v2_time_period_edition, document: non_matching_doc, lead_organisation_id: other_org_id)
    end

    context "when a single matching org_id is provided" do
      let(:org_id) { target_org_id }

      it "returns documents with editions belonging to that organisation" do
        expect(scope).to contain_exactly(matching_doc)
      end
    end

    context "when a document has multiple editions" do
      let(:org_id) { target_org_id }

      before do
        create(:v2_time_period_edition, document: matching_doc, lead_organisation_id: target_org_id)
      end

      it "returns a single document" do
        expect(scope).to contain_exactly(matching_doc)
      end
    end

    context "when an array of org_ids is provided" do
      let(:org_id) { [target_org_id, other_org_id] }

      it "returns documents matching any of the organisation IDs" do
        expect(scope).to contain_exactly(matching_doc, non_matching_doc)
      end
    end

    context "when org_id does not match any edition" do
      let(:org_id) { SecureRandom.uuid }

      it "returns an empty array" do
        expect(scope).to eq([])
      end
    end

    context "when org_id is blank" do
      [nil, "", []].each do |blank_value|
        context "when argument is #{blank_value.inspect}" do
          let(:org_id) { blank_value }

          it "returns all records as an ActiveRecord relation" do
            expect(scope).to contain_exactly(matching_doc, non_matching_doc)
            expect(scope).to be_a(ActiveRecord::Relation)
          end
        end
      end
    end
  end

  describe "date filtering scopes" do
    let(:reference_time) { Time.zone.parse("2026-06-15") }

    let!(:old_doc) { create(:v2_document) }
    let!(:new_doc) { create(:v2_document) }
    let!(:mid_doc) { create(:v2_document) }

    before do
      old_doc.update_column(:updated_at, Time.zone.parse("2026-06-10"))
      mid_doc.update_column(:updated_at, reference_time)
      new_doc.update_column(:updated_at, Time.zone.parse("2026-06-20"))
    end

    describe ".where_last_updated_after" do
      subject(:scope) { described_class.where_last_updated_after(target_date) }

      context "when a valid date is provided" do
        let(:target_date) { reference_time }

        it "returns records updated on or after the given date" do
          expect(scope).to contain_exactly(mid_doc, new_doc)
        end
      end

      context "when string or Time object formats are passed" do
        let(:target_date) { "2026-06-20" }

        it "parses and filters correctly" do
          expect(scope).to contain_exactly(new_doc)
        end
      end

      context "when argument is blank" do
        [nil, ""].each do |blank_value|
          context "when argument is #{blank_value.inspect}" do
            let(:target_date) { blank_value }

            it "returns all records as an ActiveRecord relation" do
              expect(scope).to contain_exactly(old_doc, mid_doc, new_doc)
              expect(scope).to be_a(ActiveRecord::Relation)
            end
          end
        end
      end
    end

    describe ".where_last_updated_before" do
      subject(:scope) { described_class.where_last_updated_before(target_date) }

      context "when a valid date is provided" do
        let(:target_date) { reference_time }

        it "returns records updated on or before the given date" do
          expect(scope).to contain_exactly(old_doc, mid_doc)
        end
      end

      context "when string or Time object formats are passed" do
        let(:target_date) { "2026-06-10" }

        it "parses and filters correctly" do
          expect(scope).to contain_exactly(old_doc)
        end
      end

      context "when argument is blank" do
        [nil, ""].each do |blank_value|
          context "when argument is #{blank_value.inspect}" do
            let(:target_date) { blank_value }

            it "returns all records as an ActiveRecord relation" do
              expect(scope).to contain_exactly(old_doc, mid_doc, new_doc)
              expect(scope).to be_a(ActiveRecord::Relation)
            end
          end
        end
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
      document = create(:v2_document, block_type: "time_period")
      create(:v2_time_period_edition, document: document, title: "First Edition", created_at: 1.day.ago, creator:)
      create(:v2_time_period_edition, document: document, title: "Latest Edition", created_at: Time.current, creator:)

      expect(document.title).to eq("Latest Edition")
    end

    it "returns nil when there are no editions" do
      document = create(:v2_document, block_type: "time_period")

      expect(document.title).to be_nil
    end
  end

  describe "#is_new_block?" do
    it "returns true if there is only one edition" do
      document = create(:v2_document, block_type: "time_period")
      create(:v2_time_period_edition, document: document, creator:)

      expect(document.is_new_block?).to be true
    end

    it "returns false if there are multiple editions" do
      document = create(:v2_document, block_type: "time_period")

      expect(document.is_new_block?).to be false

      create(:v2_time_period_edition, document: document, creator:)
      create(:v2_time_period_edition, document: document, creator:)

      expect(document.is_new_block?).to be false
    end
  end
end
