require "test_helper"

class PublishEditionServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#call" do
    let(:content_id) { "49453854-d8fd-41da-ad4c-f99dbac601c3" }
    let(:schema) { build(:schema, block_type: "content_block_type", body: { "properties" => { "foo" => "", "bar" => "" } }) }
    let(:document) { create(:document, :pension, content_id:, sluggable_string: "some-edition-title") }
    let(:major_change) { true }
    let(:organisation) { build(:organisation) }
    let(:edition) do
      create(
        :edition,
        document:,
        details: { "foo" => "Foo text", "bar" => "Bar text" },
        lead_organisation_id: organisation.id,
        instructions_to_publishers: "instructions",
        title: "Some Edition Title",
        change_note: "Something changed publicly",
        major_change:,
      )
    end

    setup do
      Schema.stubs(:find_by_block_type).returns(schema)
      Organisation.stubs(:all).returns([organisation])
    end

    it "returns a ContentBlockEdition" do
      result = PublishEditionService.new.call(edition)
      assert_instance_of Edition, result
    end

    it "publishes the Edition" do
      SchedulePublishingWorker.expects(:dequeue).never

      PublishEditionService.new.call(edition)
      assert_equal "published", edition.state
      assert_equal edition.id, document.live_edition_id
    end

    it "creates an Edition in the Publishing API" do
      Services.publishing_api.expects(:put_content).with(
        content_id,
        {
          schema_name: schema.id,
          document_type: schema.id,
          publishing_app: ContentBlockManager::PublishingApp::CONTENT_BLOCK_MANAGER,
          title: "Some Edition Title",
          content_id_alias: "some-edition-title",
          instructions_to_publishers: "instructions",
          details: {
            "foo" => "Foo text",
            "bar" => "Bar text",
          },
          links: {
            primary_publishing_organisation: [organisation.id],
          },
          update_type: "major",
          change_note: edition.change_note,
        },
      )

      Services.publishing_api.expects(:publish).with(content_id)

      PublishEditionService.new.call(edition)

      assert_equal "published", edition.state
      assert_equal edition.id, document.live_edition_id
    end

    describe "when the change is not major" do
      let(:major_change) { false }

      it "sends a minor update_type with no change note to the Publishing API" do
        Services.publishing_api.expects(:put_content).with do |_content_id, payload|
          payload[:update_type]
          payload[:change_note].nil?
        end

        Services.publishing_api.stubs(:publish)

        PublishEditionService.new.call(edition)

        assert_equal "published", edition.state
        assert_equal edition.id, document.live_edition_id
      end
    end

    it "rolls back the ContentBlockEdition and ContentBlockDocument if the publishing API request fails" do
      Services.publishing_api.stubs(:put_content).raises(
        GdsApi::HTTPErrorResponse.new(
          422,
          "An internal error message",
          "error" => { "message" => "Some backend error" },
        ),
      )

      assert_equal "draft", edition.state
      assert_nil document.live_edition_id

      assert_raises(GdsApi::HTTPErrorResponse) do
        PublishEditionService.new.call(edition)
      end

      assert_equal "draft", edition.state
      assert_nil document.live_edition_id
    end

    it "discards the latest draft if the publish request fails" do
      Services.publishing_api.stubs(:put_content)
      Services.publishing_api.stubs(:publish).raises(
        GdsApi::HTTPErrorResponse.new(
          422,
          "An internal error message",
          "error" => { "message" => "Some backend error" },
        ),
      )

      Services.publishing_api.expects(:discard_draft).with(content_id)

      assert_raises(PublishEditionService::PublishingFailureError, "Could not publish #{content_id} because: Some backend error") do
        PublishEditionService.new.call(edition)
      end

      assert_equal "draft", edition.state
      assert_nil document.live_edition_id
    end

    it "supersedes any previously scheduled editions" do
      scheduled_editions = create_list(:edition, 2,
                                       document:,
                                       scheduled_publication: 7.days.from_now,
                                       lead_organisation_id: organisation.id,
                                       state: "scheduled")

      scheduled_editions.each do |scheduled_edition|
        SchedulePublishingWorker.expects(:dequeue).with(scheduled_edition)
      end

      PublishEditionService.new.call(edition)

      scheduled_editions.each do |scheduled_edition|
        assert scheduled_edition.reload.superseded?
      end
    end
  end
end
