class Organisation < Data.define(:id, :name)
  class << self
    def all
      Rails.cache.fetch "organisations", expires_in: 1.day do
        api_response["results"].map { |organisation|
          new(id: organisation["content_id"], name: organisation["title"])
        }.sort_by(&:name)
      end
    end

    def find(id)
      all.find { |org| org.id == id }
    end

  private

    def api_response
      Public::Services.publishing_api.get_content_items(
        document_type: "organisation",
        fields: %w[title content_id],
        per_page: "500",
      )
    end
  end
end
