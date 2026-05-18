module Api
  class ResultsPresenter
    class << self
      def present(result, request_url)
        new(result, request_url).present
      end
    end

    def initialize(result, request_url)
      @result = result
      @request_url = URI.parse(request_url)
    end

    def present
      {
        total: result.total_count,
        pages: result.total_pages,
        current_page: result.current_page,
        links:,
        results: BlockPresenter.present_collection(result.blocks),
      }
    end

  private

    attr_reader :result, :request_url

    def links
      [previous_link, next_link, self_link].compact
    end

    def previous_link
      return unless previous_page?

      {
        href: page_href(-1),
        rel: "previous",
      }
    end

    def next_link
      return unless next_page?

      {
        href: page_href(1),
        rel: "next",
      }
    end

    def self_link
      {
        href: page_href(0),
        rel: "self",
      }
    end

    def page_href(offset)
      request_url.tap { |url|
        query_hash = Rack::Utils.parse_query(url.query)
        query_hash["page"] = result.current_page + offset
        url.query = Rack::Utils.build_query(query_hash)
      }.to_s
    end

    def previous_page?
      result.current_page > 1
    end

    def next_page?
      result.current_page < result.total_pages
    end
  end
end
