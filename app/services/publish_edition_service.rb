class PublishEditionService
  class PublishingFailureError < StandardError; end

  include Dequeueable

  def call(edition)
    publish_with_rollback(edition)
  end

private

  def publish_with_rollback(edition)
    document = edition.document
    schema = Schema.find_by_block_type(document.block_type)
    content_id = document.content_id
    content_id_alias = document.content_id_alias

    create_publishing_api_edition(
      content_id:,
      content_id_alias:,
      schema_id: schema.id,
      edition:,
    )
    dequeue_all_previously_queued_editions(edition)
    publish_publishing_api_edition(content_id:)
    update_document_with_latest_edition(edition)
    edition.public_send(:publish!)
    edition
  rescue PublishingFailureError => e
    discard_publishing_api_edition(content_id:)
    raise e
  end

  def create_publishing_api_edition(content_id:, content_id_alias:, schema_id:, edition:)
    Services.publishing_api.put_content(
      content_id,
      publishing_api_payload(schema_id, content_id_alias, edition),
    )
  end

  def publishing_api_payload(schema_id, content_id_alias, edition)
    {
      schema_name: schema_id,
      document_type: schema_id,
      publishing_app: ContentBlockManager::PublishingApp::CONTENT_BLOCK_MANAGER,
      title: edition.title,
      instructions_to_publishers: edition.instructions_to_publishers,
      content_id_alias:,
      details: edition.details,
      links: {
        primary_publishing_organisation: [
          edition.lead_organisation.id,
        ],
      },
      update_type: edition.major_change ? "major" : "minor",
      change_note: edition.major_change ? edition.change_note : nil,
    }
  end

  def publish_publishing_api_edition(content_id:)
    Services.publishing_api.publish(content_id)
  rescue GdsApi::HTTPErrorResponse => e
    raise PublishingFailureError, "Could not publish #{content_id} because: #{e.message}"
  end

  def update_document_with_latest_edition(edition)
    edition.document.update!(
      latest_edition_id: edition.id,
      live_edition_id: edition.id,
    )
  end

  def discard_publishing_api_edition(content_id:)
    Services.publishing_api.discard_draft(content_id)
  end
end
