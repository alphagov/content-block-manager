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
