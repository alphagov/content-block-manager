RSpec.describe FactCheck::BlocksController, type: :feature do
  include FactCheck::Engine.routes.url_helpers

  before do
    logout
    user = create(:user)
    login_as(user)
  end

  describe "#show" do
    let(:block) { build(:content_block) }
    let(:content_id) { "some-content-block" }

    before do
      expect(ContentBlock).to receive(:from_content_id_alias).with(content_id).and_return(block)
      allow(block).to receive(:state).and_return("awaiting_factcheck")
    end

    it "returns information about a block" do
      visit block_path(content_id)

      expect(page).to have_css ".govuk-heading-xl", text: block.title
      expect(page).to have_css ".govuk-caption-xl", text: block.block_type
      expect(page).to have_css ".govuk-tag--pink", text: "In factcheck"
    end

    context "when the block is not embeddable as a block" do
      before do
        allow(block).to receive(:embeddable_as_block?).and_return(false)
      end

      it "does not show a comparison of the default block" do
        visit block_path(content_id)

        expect(page).to_not have_css ".govuk-summary-card__title", text: "Default block"
      end
    end

    context "when the block is embeddable as a block" do
      let(:published_block) { build(:content_block) }

      before do
        allow(block).to receive(:embeddable_as_block?).and_return(true)
        allow(block).to receive(:published_block).and_return(published_block)
      end

      it "shows a comparison of the default block" do
        visit block_path(content_id)

        expect(page).to have_css ".govuk-summary-card__title", text: "Default block"
      end
    end
  end
end
