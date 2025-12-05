module PublishingApi
  RSpec.describe PublishIntentPresenter do
    it "it returns the publish intent" do
      base_path = "/example-path"
      publish_timestamp = Time.zone.now.to_s

      presenter = PublishingApi::PublishIntentPresenter.new(base_path, publish_timestamp)
      expected_hash = {
        publish_time: publish_timestamp,
        publishing_app: ContentBlockManager::PublishingApp::CONTENT_BLOCK_MANAGER,
        routes: [{ path: base_path, type: "exact" }],
      }

      expect(expected_hash).to eq(presenter.as_json)
    end
  end
end
