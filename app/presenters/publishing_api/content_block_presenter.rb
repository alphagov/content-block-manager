module PublishingApi
  class ContentBlockPresenter
    def initialize(schema_id:, content_id_alias:, edition:)
      @schema_id = schema_id
      @content_id_alias = content_id_alias
      @edition = edition
    end

    def present
      {
        schema_name: schema_id,
        document_type: schema_id,
        publishing_app: ContentBlockManager::PublishingApp::CONTENT_BLOCK_MANAGER,
        title: edition.title,
        instructions_to_publishers: edition.instructions_to_publishers,
        content_id_alias:,
        base_path:,
        details: edition.details,
        links:,
        update_type:,
        change_note:,
        routes:,
      }
    end

  private

    attr_reader :schema_id, :content_id_alias, :edition

    def links
      {
        primary_publishing_organisation: [
          edition.lead_organisation.id,
        ],
      }
    end

    def update_type
      edition.major_change ? "major" : "minor"
    end

    def change_note
      edition.major_change ? edition.change_note : nil
    end

    def base_path
      "/content-blocks/#{schema_id}/#{content_id_alias}"
    end

    def routes
      [
        {
          path: base_path,
          type: "exact",
        },
      ]
    end
  end
end
