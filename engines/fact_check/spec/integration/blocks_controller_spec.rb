RSpec.describe FactCheck::BlocksController, type: :feature do
  include FactCheck::Engine.routes.url_helpers

  before do
    logout
    user = create(:user)
    login_as(user)
  end

  describe "#show" do
    it "returns information about a block" do
      block = build(:content_block)
      expect(ContentBlock).to receive(:from_content_id_alias).with("some-content-block").and_return(block)

      visit block_path("some-content-block")

      expect(page).to have_css ".govuk-heading-xl", text: block.title
      expect(page).to have_css ".govuk-caption-xl", text: block.block_type
    end
  end
end
