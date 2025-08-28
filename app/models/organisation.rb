class Organisation < Data.define(:id, :name)
  class << self
    def all
      Rails.cache.fetch "organisations", expires_in: 1.day do
        api_response = Services.publishing_api.get_content_items(document_type: "organisation", per_page: "500")
        api_response["results"].map do |organisation|
          new(id: organisation["content_id"], name: organisation["title"])
        end
      end
    end

    def find(id)
      all.find { |org| org.id == id }
    end
  end
end
