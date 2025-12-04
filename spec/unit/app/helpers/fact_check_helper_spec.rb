RSpec.describe FactCheckHelper, type: :helper do
  include FactCheckHelper

  describe ".fact_check_url_with_token" do
    it "returns the fact check URL for an edition with the bypass token" do
      document = build(:document)
      edition = build(:edition, document:)

      allow(document).to receive(:content_id_alias).and_return("some-alias")
      allow(edition).to receive(:auth_bypass_token).and_return("auth_bypass_token")

      expect(fact_check_url_with_token(edition)).to eq(
        FactCheck::Engine.routes.url_helpers.block_url(
          host: ContentBlockManager.admin_root,
          id: "some-alias",
          token: "auth_bypass_token",
        ),
      )
    end
  end
end
