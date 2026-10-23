RSpec.describe V2::Version, type: :model do
  it { is_expected.to have_many(:domain_events).class_name("V2::DomainEvent").with_foreign_key(:v2_version_id) }
  it { is_expected.to belong_to(:item) }
  it { is_expected.to belong_to(:user).class_name("User").with_foreign_key(:whodunnit).optional }

  let(:event) { "created" }
  let(:item) do
    create(
      :v2_edition,
      document: create(:v2_document),
    )
  end
  let(:whodunnit) { SecureRandom.uuid }
  let(:field_diffs) do
    {
      "some_field" => DiffItem.new(previous_value: "previous value", new_value: "new value"),
    }
  end

  let(:version) do
    V2::Version.new(
      event: event,
      item: item,
      whodunnit: whodunnit,
    )
  end

  it "exists with required data" do
    version.save!

    expect(version.event).to eq(event)
    expect(version.item).to eq(item)
    expect(version.whodunnit).to eq(whodunnit)
  end

  it "exists with optional state" do
    version.update!(state: "scheduled")

    expect(version.state).to eq("scheduled")
  end

  it "exists with optional field_diffs" do
    version.update!(field_diffs:)

    expect(version.field_diffs).to eq(field_diffs)
  end

  it "validates the presence of a correct event" do
    expect {
      create(:v2_version, event: "invalid")
    }.to raise_error(ArgumentError)
  end

  describe "::increment_for_edition" do
    let(:document) { create(:v2_document) }
    let(:edition) { create(:v2_edition, document: document) }
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
      V2::Version.increment_for_edition(**args)
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

      version.field_diffs = hash

      expect(version.field_diffs).to eq(DiffItem.from_hash(hash))
    end

    it "returns an empty hash when the value is nil" do
      version.field_diffs = nil

      expect(version.field_diffs).to eq(({}))
    end
  end
end
