require "gds_api/publishing_api"
require "gds_api/asset_manager"
require "gds_api/search"

module Public::Services
  def self.publishing_api
    @publishing_api ||= publishing_api_client_with_timeout(20)
  end

  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(Plek.find("content-store"))
  end

  def self.draft_content_store
    @draft_content_store ||= GdsApi::ContentStore.new(Plek.find("draft-content-store"))
  end

  def self.publishing_api_client_with_timeout(timeout)
    GdsApi::PublishingApi.new(
      Plek.find("publishing-api"),
      bearer_token: ENV.fetch("PUBLISHING_API_BEARER_TOKEN", "example"),
      timeout:,
    )
  end
end
