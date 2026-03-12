module PublishingApi
  class ContentBlockPresenter
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
        base_path:,
        details: edition.details,
        links:,
        update_type:,
        change_note:,
        routes:,
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
      edition.major_change ? "major" : "minor"
    end

    def change_note
      edition.major_change ? edition.change_note : nil
    end

    def base_path
      "/content-blocks/#{document_type}/#{content_id_alias}"
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
