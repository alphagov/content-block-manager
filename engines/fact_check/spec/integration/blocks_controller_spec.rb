RSpec.describe FactCheck::BlocksController, type: :feature do
  include FactCheck::Engine.routes.url_helpers

  before do
    logout
    user = create(:user)
    login_as(user)

    allow_any_instance_of(Shared::HostEditionsTableComponent)
      .to receive_message_chain(:helpers, :main_app, :host_content_preview_edition_path)
            .and_return("/fake/path")
    allow_any_instance_of(Shared::HostEditionsTableComponent)
      .to receive_message_chain(:helpers, :url_for)
            .and_return("/fake/path")
    allow_any_instance_of(Shared::HostEditionsTableComponent)
      .to receive_message_chain(:helpers, :main_app, :user_path)
            .and_return("/fake/path")
  end

  describe "#show" do
    let(:block) { build(:content_block) }
    let(:content_id) { "some-content-block" }
    let(:item_count) { 4 }
    let(:host_content_items) { build(:host_content_items, items: build_list(:host_content_item, item_count)) }

    before do
      expect(ContentBlock).to receive(:from_content_id_alias).with(content_id).and_return(block)
      allow(block).to receive(:state).and_return("awaiting_factcheck")
      allow(block).to receive(:id).and_return(123)
      allow(HostContentItem).to receive(:for_document).and_return(host_content_items)
    end

    it "returns information about a block" do
      visit block_path(content_id)

      expect(page).to have_css ".govuk-heading-xl", text: block.title
      expect(page).to have_css ".govuk-caption-xl", text: block.block_type
      expect(page).to have_css ".govuk-tag--pink", text: "In fact check"
    end

    it "shows the list of host editions referencing the block" do
      visit block_path(content_id)

      expect(page).to have_css "#host_editions", text: "List of locations" do |component|
        expect(component).to have_content "My document type", count: item_count
        expect(component).to have_content "My Item Title", count: item_count * 2 # Title appears twice in each row (once as text, once as link)
      end
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
