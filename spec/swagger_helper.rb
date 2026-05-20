require "spec_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("engines/api/swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Content Block Manager API",
        version: "v1",
        description: <<~DESC,
          The Content Block Manager API allows users to view information about content blocks. It is largely designed
          for use by the [authoring widget](https://github.com/alphagov/content-block-editor) to allow preview and
          search of content blocks.

          Currently, only search is supported, but in the future, we plan to support rendering of content blocks.

          At the moment, the API is read-only, and only supports searching for published content blocks, but in the
          future, we may add support for draft content blocks and for creating and updating content blocks, which will
          require authentication.
        DESC
      },
      paths: {},
      servers: [
        {
          url: "#{Plek.new('publishing.service.gov.uk').find('content-block-manager')}/api",
        },
      ],
    },
  }
end
