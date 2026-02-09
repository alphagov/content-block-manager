RSpec.describe FactCheck::BlocksController, type: :request do
  include FactCheck::Engine.routes.url_helpers

  describe "#show" do
    let(:block) { build(:content_block) }
    let(:content_id) { "some-content-block" }
    let(:host_content_items) { build(:host_content_items, items: []) }

    let(:path) { block_path(content_id) }

    before do
      allow_any_instance_of(Shared::HostEditionsTableComponent)
        .to receive_message_chain(:helpers, :main_app, :host_content_preview_edition_path)
              .and_return("/fake/path")
      allow_any_instance_of(Shared::HostEditionsTableComponent)
        .to receive_message_chain(:helpers, :url_for)
              .and_return("/fake/path")
      allow_any_instance_of(Shared::HostEditionsTableComponent)
        .to receive_message_chain(:helpers, :main_app, :user_path)
              .and_return("/fake/path")

      allow(ContentBlock).to receive(:from_content_id_alias).with(content_id).and_return(block)
      allow(HostContentItem).to receive(:for_document).and_return(host_content_items)
    end

    include_examples "allows authentication with a JWT"
  end
end
