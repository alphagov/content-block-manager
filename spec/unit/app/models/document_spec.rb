RSpec.describe Document, type: :model do
  it { is_expected.to have_many(:domain_events) }

  it "exists with required data" do
    document = create(
      :document,
      :pension,
      content_id: "52084b2d-4a52-4e69-ba91-3052b07c7eb6",
      sluggable_string: "Title",
      created_at: Time.zone.local(2000, 12, 31, 23, 59, 59).utc,
      updated_at: Time.zone.local(2000, 12, 31, 23, 59, 59).utc,
    )

    aggregate_failures do
      expect("52084b2d-4a52-4e69-ba91-3052b07c7eb6").to eq(document.content_id)
      expect("Title").to eq(document.sluggable_string)
      expect("pension").to eq(document.block_type)
      expect(Time.zone.local(2000, 12, 31, 23, 59, 59).utc).to eq(document.created_at)
      expect(Time.zone.local(2000, 12, 31, 23, 59, 59).utc).to eq(document.updated_at)
      expect("title").to eq(document.content_id_alias)
    end
  end

  it "does not allow the block type to be changed" do
    document = create(:document, :pension)

    expect {
      document.update(block_type: "something_else")
    }.to raise_error(ActiveRecord::ReadonlyAttributeError)
  end

  it "gets its version history from its editions" do
    document = create(:document, :pension)
    edition = create(
      :edition,
      document:,
      creator: create(:user),
    )
    document.update!(editions: [edition])

    expect(document.versions.first.item.id).to eq(edition.id)
  end

  describe "embed_code" do
    let(:content_id) { SecureRandom.uuid }
    let(:content_id_alias) { "some-alias" }
    let(:document) { create(:document, :pension, content_id:, content_id_alias:) }

    it "returns embed code for the document" do
      expect(document.embed_code).to eq("{{embed:content_block_pension:#{content_id_alias}}}")
    end

    it "returns embed code for a particular field" do
      expect(document.embed_code_for_field("rates/rate2/name")).to eq(
        "{{embed:content_block_pension:#{content_id_alias}/rates/rate2/name}}",
      )
    end
  end

  describe "latest_published_edition" do
    let(:document) { create(:document, :pension) }

    let!(:draft_edition) do
      create(
        :edition,
        :draft,
        document: document,
        updated_at: Time.current,
      )
    end

    let!(:latest_published_edition) do
      create(
        :edition,
        :published,
        document: document,
        updated_at: Time.current,
      )
    end

    let!(:earlier_published_edition) do
      create(
        :edition,
        :published,
        document: document,
        updated_at: 2.years.ago,
      )
    end

    it "returns the most recent published edition" do
      expect(document.latest_published_edition).to eq(latest_published_edition)
    end
  end

  describe "#most_recent_edition" do
    let(:document) { create(:document, :pension) }

    before do
      create(:edition, document: document, updated_at: Time.zone.now - 2.weeks, state: :published)
      create(:edition, document: document, updated_at: Time.zone.now - 12.days, state: :published)
      create(:edition, document: document, updated_at: Time.zone.now - 7.days, state: :published)
    end

    describe "with active states" do
      Edition.active_states.each do |state|
        context "when the most recent edition is #{state}" do
          let!(:most_recent_edition) { create(:edition, state, document: document, updated_at: Time.zone.now - 1.day) }

          it "returns the #{state} edition" do
            expect(document.most_recent_edition).to eq(most_recent_edition)
          end
        end
      end
    end

    describe "with inactive states" do
      Edition.inactive_states.each do |state|
        context "when the most recent edition is #{state}" do
          let!(:most_recent_edition) { create(:edition, state, document: document, updated_at: Time.zone.now - 1.day) }

          Edition.active_states.each do |active_state|
            context "when the most recent active edition is #{active_state}" do
              let!(:most_recent_active_edition) { create(:edition, active_state, document: document, updated_at: Time.zone.now - 2.days) }

              it "returns the #{active_state} edition" do
                expect(document.most_recent_edition).to eq(most_recent_active_edition)
              end
            end
          end
        end
      end
    end
  end

  describe ".live" do
    let(:document_with_published_edition) do
      create(:document, :pension).tap do |doc|
        create(:edition, :published, document: doc)
      end
    end

    before do
      create(:document, :pension).tap do |doc|
        create(:edition, :draft, document: doc)
      end
    end

    it "only returns documents with a published edition" do
      expect(Document.live).to eq([document_with_published_edition])
    end
  end

  describe "friendly_id" do
    it "generates a content_id_alias" do
      document = create(
        :document,
        :pension,
        sluggable_string: "This is a title",
      )

      expect(document.content_id_alias).to eq("this-is-a-title")
    end

    it "ensures content_id_aliases are unique" do
      documents = create_list(
        :document,
        2,
        :pension,
        sluggable_string: "This is a title",
      )

      expect(documents[0].content_id_alias).to eq("this-is-a-title")
      expect(documents[1].content_id_alias).to eq("this-is-a-title--2")
    end

    it "does not change the alias if the sluggable string changes" do
      document = create(
        :document,
        :pension,
        sluggable_string: "This is a title",
      )

      document.sluggable_string = "Something else"
      document.save!

      expect(document.content_id_alias).to eq("this-is-a-title")
    end
  end

  describe "title" do
    it "returns the latest edition's title" do
      document = create(:document, :pension)
      _oldest_edition = create(:edition, :published, document:, updated_at: 1.year.ago)
      latest_edition = create(:edition, :published, document:, title: "I am the latest edition", updated_at: Time.current)

      expect(document.title).to eq(latest_edition.title)
    end
  end

  describe "#is_new_block?" do
    it "returns true when there is one associated edition" do
      document = create(:document, :pension, editions: create_list(:edition, 1, :pension))

      expect(document.is_new_block?).to be true
    end

    it "returns false when there is more than one associated edition" do
      document = create(:document, :pension, editions: create_list(:edition, 2, :pension))

      expect(document.is_new_block?).to be false
    end
  end

  describe "#latest_draft" do
    let(:document) { create(:document, :pension) }

    it "returns the latest draft edition" do
      _older_draft = create(:edition, :pension, created_at: Time.zone.now - 2.days, document:, state: "draft")
      newest_draft = create(:edition, :pension, created_at: Time.zone.now - 1.day, document:, state: "draft")
      _newest_edition = create(:edition, :pension, created_at: Time.zone.now, document:, state: "published")

      expect(document.latest_draft).to eq(newest_draft)
    end
  end

  describe "#schema" do
    let(:document) { build(:document, :pension) }
    let(:schema) { build(:schema) }

    before do
      # remove the stubbing set in factory
      allow(document).to receive(:schema).and_call_original
    end

    it "returns a schema object" do
      allow(Schema).to receive(:find_by_block_type)
        .with(document.block_type)
        .and_return(schema)

      expect(document.schema).to eq(schema)
    end
  end
end
