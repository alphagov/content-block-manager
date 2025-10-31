RSpec.describe Edition::HasAuditTrail do
  let(:user) { create("user") }
  let(:organisation) { build(:organisation) }
  let(:document) { build(:document, :pension) }

  describe "record_create" do
    it "creates a 'created' version with the current user" do
      Current.user = user
      edition = build(
        :edition,
        creator: user,
        document: create(:document, :pension),
      )

      expect { edition.save }.to change { edition.versions.count }.from(0).to(1)
      version = edition.versions.first

      expect(version.whodunnit).to eq(user.id.to_s)
      expect(version.event).to eq("created")
    end
  end

  describe "record_update" do
    it "creates a 'updated' version after scheduling an edition" do
      Current.user = user
      edition = create(
        :edition,
        creator: user,
        document: create(:document, :pension),
      )
      edition.scheduled_publication = Time.zone.now + 1.day
      expect(edition).to receive(:generate_diff).and_return({})

      expect { edition.schedule! }.to change { edition.versions.count }.from(1).to(2)

      version = edition.versions.first

      expect(version.whodunnit).to eq(user.id.to_s)
      expect(version.event).to eq("updated")
      expect(version.state).to eq("scheduled")
    end

    it "adds event details if provided" do
      Current.user = user
      edition = create(
        :edition,
        creator: user,
        document: create(:document, :pension),
      )
      expect(edition).to receive(:generate_diff).and_return({})
      edition.updated_embedded_object_type = "something"
      edition.updated_embedded_object_title = "here"

      expect { edition.publish! }.to change { edition.versions.count }.from(1).to(2)

      version = edition.versions.first

      expect(version.updated_embedded_object_type).to eq(edition.updated_embedded_object_type)
      expect(version.updated_embedded_object_title).to eq(edition.updated_embedded_object_title)
    end

    it "does not record a version when updating an existing draft" do
      edition = create(
        :edition,
        document: create(:document, :pension),
        state: "draft",
      )

      expect { edition.update!(details: { "foo": "bar" }) }.not_to(change { edition.versions.count })
    end

    it "checks for any field_diffs" do
      Current.user = user
      edition = create(
        :edition,
        creator: user,
        document: create(:document, :pension),
      )
      edition.scheduled_publication = Time.zone.now + 1.day

      expect(edition).to receive(:generate_diff).and_return({})
      edition.schedule!
    end
  end

  describe "acting_as" do
    before do
      @user = create(:user)
      @user2 = create(:user)
    end

    it "changes Current.user for the duration of the block, reverting to the original user afterwards" do
      Current.user = @user

      Edition::HasAuditTrail.acting_as(@user2) do
        expect(Current.user).to eq(@user2)
      end

      expect(Current.user).to eq(@user)
    end

    it "reverts Current.user, even when an exception is thrown" do
      Current.user = @user

      expect {
        Edition::HasAuditTrail.acting_as(@user2) { raise "Boom!" }
      }.to raise_error("Boom!")
      expect(Current.user).to eq(@user)
    end
  end

  describe "versions" do
    it "returns versions in descending order based on datetime" do
      edition = create(
        :edition,
        document: create(:document, :pension),
      )
      newer_version = edition.versions.first
      oldest_version = create(
        :content_block_version,
        created_at: 2.days.ago,
        item: edition,
      )
      middle_version = create(
        :content_block_version,
        created_at: 1.day.ago,
        item: edition,
      )
      expect(newer_version).to eq(edition.versions.first)
      expect(oldest_version).to eq(edition.versions.last)
      expect(middle_version).to eq(edition.versions.[](1))
    end

    it "returns versions in descending order based on id" do
      edition = create(
        :edition,
        document: create(:document, :pension),
      )
      first_version = edition.versions.first
      second_version = create(
        :content_block_version,
        item: edition,
      )
      third_version = create(
        :content_block_version,
        item: edition,
      )
      expect(third_version).to eq(edition.versions.first)
      expect(second_version).to eq(edition.versions.[](1))
      expect(first_version).to eq(edition.versions.last)
    end
  end
end
