require "test_helper"
require "rake"

class DeleteContentBlockTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:content_id) { SecureRandom.uuid }
  let(:task) { Rake::Task["delete_content_block"] }

  teardown do
    Rake::Task["delete_content_block"].reenable
  end

  describe "when a content block exists" do
    let!(:document) { create(:document, :pension, content_id:) }
    let!(:editions) { create_list(:edition, 5, document: document) }

    it "returns an error if the document has host content" do
      stub_response = stub("HostContentItem::Items", items: stub(count: 2))
      HostContentItem.stubs(:for_document).with(document).returns(stub_response)

      assert_raises RuntimeError, "Content block `#{content_id}` cannot be deleted because it has host content. Try removing the dependencies and trying again" do
        Rake::Task["delete_content_block[#{content_id}]"].execute
      end

      document.reload

      assert_not document.soft_deleted?
    end

    describe "when the document does not have host content" do
      before do
        stub_response = stub("HostContentItem::Items", items: stub(count: 0))
        HostContentItem.stubs(:for_document).with(document).returns(stub_response)
      end

      it "destroys the content block" do
        Services.publishing_api.expects(:unpublish).with(
          content_id,
          type: "vanish",
          locale: "en",
          discard_drafts: true,
        )

        Rake.application.invoke_task("delete_content_block[#{content_id}]")

        document.reload

        assert document.soft_deleted?
      end
    end
  end

  it "returns an error if the content block cannot be found" do
    assert_raises RuntimeError, "A content block with the content ID `#{content_id}` cannot be found" do
      Rake::Task["delete_content_block[#{content_id}]"].execute
    end
  end
end
