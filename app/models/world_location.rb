class WorldLocation < Data.define(:name)
  class << self
    def countries
      Rails.cache.fetch "world_locations", expires_in: 1.day do
        api_response["results"]
          .map { |location| new(name: location["title"]) }
          .sort_by(&:name)
      end
    end

  private

    def api_response
      Services.publishing_api.get_content_items(
        document_type: "world_location",
        fields: %w[title],
        per_page: "500",
      )
    end
  end
end
