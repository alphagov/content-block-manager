class HostContentItem < Data.define(
  :title,
  :base_path,
  :document_type,
  :publishing_organisation,
  :publishing_app,
  :last_edited_by_editor,
  :last_edited_at,
  :unique_pageviews,
  :instances,
  :host_content_id,
  :host_locale,
)
  DEFAULT_ORDER = "-unique_pageviews".freeze

  class << self
    def for_document(document, page: nil, order: nil)
      api_response = Public::Services.publishing_api.get_host_content_for_content_id(
        document.content_id,
        {
          page:,
          order: order || DEFAULT_ORDER,
        }.compact,
      ).parsed_content

      editor_uuids = api_response["results"].map { |c| c["last_edited_by_editor_id"] }.compact.uniq
      editors = editor_uuids.present? ? SignonUser.with_uuids(editor_uuids) : []

      items = api_response["results"].map do |record|
        from_api_record(record, editors)
      end

      HostContentItem::Items.new(
        items:,
        total: api_response["total"],
        total_pages: api_response["total_pages"],
        rollup: rollup(api_response),
      )
    rescue GdsApi::HTTPNotFound
      HostContentItem::Items.new(
        items: [],
        total: 0,
        total_pages: 0,
        rollup: HostContentItem::Items::Rollup.new(
          views: 0,
          locations: 0,
          instances: 0,
          organisations: 0,
        ),
      )
    end

  private

    def rollup(api_response)
      HostContentItem::Items::Rollup.new(
        views: api_response["rollup"]["views"],
        locations: api_response["rollup"]["locations"],
        instances: api_response["rollup"]["instances"],
        organisations: api_response["rollup"]["organisations"],
      )
    end

    def from_api_record(record, editors)
      new(
        title: record["title"],
        base_path: record["base_path"],
        document_type: record["document_type"],
        publishing_organisation: record["primary_publishing_organisation"],
        publishing_app: record["publishing_app"],
        last_edited_by_editor: editors.find { |editor| editor.uid == record["last_edited_by_editor_id"] },
        last_edited_at: record["last_edited_at"],
        unique_pageviews: record["unique_pageviews"],
        instances: record["instances"],
        host_content_id: record["host_content_id"],
        host_locale: record["host_locale"],
      )
    end
  end

  def last_edited_at
    Time.zone.parse(super)
  end
end
