module PublishingApi
  class V2ContentBlockPresenter
    def initialize(document_type:, content_id_alias:, edition:)
      @document_type = document_type
      @content_id_alias = content_id_alias
      @edition = edition
    end

    def present
      {
        schema_name: "content_block",
        document_type:,
        publishing_app: ContentBlockManager::PublishingApp::CONTENT_BLOCK_MANAGER,
        title: edition.title,
        instructions_to_publishers: edition.instructions_to_publishers,
        content_id_alias:,
        details: edition.to_details,
        links:,
        update_type:,
        change_note:,
      }
    end

  private

    attr_reader :document_type, :content_id_alias, :edition

    def links
      {
        primary_publishing_organisation: [
          edition.lead_organisation.id,
        ],
      }
    end

    def update_type
      "minor"
    end

    def change_note
      nil
    end
  end
end
