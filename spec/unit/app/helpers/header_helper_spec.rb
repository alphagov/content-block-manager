RSpec.describe HeaderHelper, type: :helper do
  describe "#navigation_items" do
    context "when the user is signed in" do
      let(:user) { build(:user) }

      it "returns the navigation items" do
        expect(navigation_items(user)).to eq([
          main_nav_item("Blocks", root_path),
          {
            text: "View website",
            href: ContentBlockManager.public_root,
          },
          {
            text: "Switch app",
            href: Plek.external_url_for("signon"),
          },
        ])
      end
    end

    context "when the user is not signed in" do
      let(:user) { nil }

      it "returns an empty array" do
        expect(navigation_items(user)).to eq([])
      end
    end
  end
end
