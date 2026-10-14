RSpec.describe HeaderHelper, type: :helper do
  describe "#navigation_items" do
    context "when the user is signed in" do
      context "without the view_metrics permission" do
        let(:user) { build(:user, permissions: [User::Permissions::SIGNIN]) }

        it "doesn't include a link to the metrics" do
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

      context "with the view_metrics permission" do
        let(:user) { build(:user, permissions: [User::Permissions::SIGNIN, User::Permissions::VIEW_METRICS]) }

        it "includes a link to the metrics, after the blocks" do
          expect(navigation_items(user)).to eq([
            main_nav_item("Blocks", root_path),
            main_nav_item("Metrics", admin_metrics_host_content_path),
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
    end

    context "when the user is not signed in" do
      let(:user) { nil }

      it "returns an empty array" do
        expect(navigation_items(user)).to eq([])
      end
    end
  end
end
