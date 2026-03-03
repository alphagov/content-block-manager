require "gds_api/publishing_api"
require "gds_api/test_helpers/publishing_api"

UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
PUBLISHING_API_V2_ENDPOINT = "#{Plek.find('publishing-api')}/v2".freeze

Before do
  # Stub publish intent requests
  stub_request(:any, %r{\A#{Plek.find('publishing-api')}/publish-intent/})

  # Stub requests to send draft content to the Publishing API
  stub_request(:put, %r{\A#{PUBLISHING_API_V2_ENDPOINT}/content/#{UUID_REGEX}})

  stub_request(:get, %r{\A#{PUBLISHING_API_V2_ENDPOINT}/schemas}).to_return(body: { schemas: [] }.to_json)

  # Stub requests to publish content
  stub_request(:post, %r{\A#{PUBLISHING_API_V2_ENDPOINT}/content/#{UUID_REGEX}/publish})

  # Stub requests to get links and expanded links
  stub_request(:get, %r{\A#{PUBLISHING_API_V2_ENDPOINT}/links})
    .to_return(body: { links: {} }.to_json)
  stub_request(:get, %r{\A#{PUBLISHING_API_V2_ENDPOINT}/expanded-links})
    .to_return(body: { expanded_links: {} }.to_json)

  # Stub requests for World Locations
  stub_request(:get, %r{\A#{PUBLISHING_API_V2_ENDPOINT}/content\?document_type=world_location})
    .to_return(body: { results: [{ title: "United Kingdom" }] }.to_json)
end

World(GdsApi::TestHelpers::PublishingApi)
