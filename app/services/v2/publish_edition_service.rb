module V2
  class PublishEditionService
    class PublishingFailureError < StandardError; end

    def call(edition)
      publish_with_rollback(edition)
    end

  private

    def publish_with_rollback(edition)
      document = edition.document
      block_type = document.block_type
      content_id = document.content_id
      content_id_alias = document.content_id_alias

      create_publishing_api_edition(
        content_id:,
        content_id_alias:,
        document_type: "content_block_#{block_type}",
        edition:,
      )
      publish_publishing_api_edition(content_id:)
      edition.public_send(:publish!)
      edition
    rescue PublishingFailureError => e
      discard_publishing_api_edition(content_id:)
      raise e
    end

    def create_publishing_api_edition(content_id:, content_id_alias:, document_type:, edition:)
      Public::Services.publishing_api.put_content(
        content_id,
        publishing_api_payload(document_type, content_id_alias, edition),
      )
    end

    def publishing_api_payload(document_type, content_id_alias, edition)
      PublishingApi::V2ContentBlockPresenter.new(document_type:, content_id_alias:, edition:).present
    end

    def publish_publishing_api_edition(content_id:)
      Public::Services.publishing_api.publish(content_id)
    rescue GdsApi::HTTPErrorResponse => e
      raise PublishingFailureError, "Could not publish #{content_id} because: #{e.message}"
    end

    def discard_publishing_api_edition(content_id:)
      Public::Services.publishing_api.discard_draft(content_id)
    end
  end
end
