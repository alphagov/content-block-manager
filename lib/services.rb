require "gds_api/publishing_api"
require "gds_api/asset_manager"
require "gds_api/search"

module Services
  def self.publishing_api
    @publishing_api ||= publishing_api_client_with_timeout(20)
  end

  def self.publishing_api_client_with_timeout(timeout)
    GdsApi::PublishingApi.new(
      Plek.find("publishing-api"),
      bearer_token: ENV.fetch("PUBLISHING_API_BEARER_TOKEN", "example"),
      timeout:,
    )
  end

  def self.signon_api_client
    GdsApi::SignonApi.new(
      Plek.find("signon", external: true),
      bearer_token: ENV.fetch("SIGNON_API_BEARER_TOKEN", "example"),
    )
  end
end
