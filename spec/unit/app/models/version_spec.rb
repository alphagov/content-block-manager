RSpec.describe Version, type: :model do
  it { is_expected.to have_many(:domain_events) }

  let(:event) { "created" }
  let(:item) do
    create(
      :edition,
      document: create(:document, :pension),
    )
  end
  let(:whodunnit) { SecureRandom.uuid }
  let(:field_diffs) do
    {
      "some_field" => DiffItem.new(previous_value: "previous value", new_value: "new value"),
    }
  end

  let(:content_block_version) do
    Version.new(
      event:,
      item:,
      whodunnit:,
    )
  end

  it "exists with required data" do
    content_block_version.save!

    expect(content_block_version.event).to eq(event)
    expect(content_block_version.item).to eq(item)
    expect(content_block_version.whodunnit).to eq(whodunnit)
  end

  it "exists with optional state" do
    content_block_version.update!(state: "scheduled")

    expect(content_block_version.state).to eq("scheduled")
  end

  it "exists with optional field_diffs" do
    content_block_version.update!(field_diffs:)

    expect(content_block_version.field_diffs).to eq(field_diffs)
  end

  it "validates the presence of a correct event" do
    assert_raises(ArgumentError) do
      _content_block_version = create(
        :content_block_version,
        event: "invalid",
      )
    end
  end

  describe "::increment_for_edition" do
    let(:document) { create(:document) }
    let(:edition) { create(:edition, document: document) }
    let(:user) { create(:user) }
    let(:diffs) do
      {
        "field_name" => { "previous_value" => "bar", "new_value" => "baz" },
      }
    end

    let(:args) do
      {
        user: user,
        edition: edition,
        state: "published",
        field_diffs: diffs,
      }
    end

    let(:version) do
      Version.increment_for_edition(**args)
    end

    it("creates a Version using the given arguments") do
      aggregate_failures do
        expect(version.whodunnit).to eq(user.id.to_s)
        expect(version.item).to eq(edition)
        expect(version.state).to eq("published")
        expect(version.field_diffs).to eq(DiffItem.from_hash(diffs))
      end
    end
  end

  describe "#field_diffs" do
    it "returns the field diffs as typed objects" do
      hash = {
        "foo" => { "previous_value" => "bar", "new_value" => "baz" },
      }

      content_block_version.field_diffs = hash

      expect(content_block_version.field_diffs).to eq(DiffItem.from_hash(hash))
    end

    it "returns an empty hash when the value is nil" do
      content_block_version.field_diffs = nil

      expect(content_block_version.field_diffs).to eq(({}))
    end
  end
end
