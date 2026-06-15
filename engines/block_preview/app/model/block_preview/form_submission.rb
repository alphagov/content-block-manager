# Represents a form submission to a GOV.UK frontend and its resulting
# redirect behaviour. Only allows requests to known frontend hosts
# as determined by Plek.
#
# @example Basic usage
#   submission = FormSubmission.new(
#     url: "https://www.gov.uk/form",
#     body: { field: "value" },
#     method: "post"
#   )
#   path = submission.redirect_path
#
module BlockPreview
  class FormSubmission
    # @return [URI] The parsed URI of the target URL
    # @example
    #   URI("https://www.gov.uk/form")
    attr_reader :uri

    # @return [Hash] The form data to be submitted
    # @example
    #   { field: "value" }
    attr_reader :body

    # @return [String] The HTTP method to use for the request
    # @example
    #   "post"
    attr_reader :method

    # Raised when the HTTP response is not as expected
    class UnexpectedResponseError < StandardError; end

    # Raised when the URL host is not in the allowed frontend hosts
    class UnexpectedUrlError < StandardError; end

    # Initializes a new FormSubmission.
    #
    # @param url [String] The target URL to submit the form to
    # @param body [Hash] The form data to be submitted
    # @param method [String] The HTTP method to use for the request
    # @raise [UnexpectedUrlError] if the URL host is not an allowed
    #   frontend host
    #
    def initialize(url:, body:, method:)
      @uri = URI.parse(url)
      @body = body
      @method = method
      raise UnexpectedUrlError unless allowed_host?
    end

    # The path component of the redirect location resulting from the submission.
    #
    # @return [String] The path component of the redirect location
    # @raise [UnexpectedResponseError] if the response is not a 302 redirect or a http(s) URI
    #
    def redirect_path
      raise UnexpectedResponseError unless response.status == 302

      location = URI.parse(response.headers["location"])
      raise UnexpectedResponseError unless http_uri?(location)

      location.request_uri
    end

    def self.allowed_hosts
      [
        Plek.website_root,
        Plek.external_url_for("draft-origin"),
      ].map { |url| URI.parse(url).host }.compact.uniq
    end

  private

    def allowed_host?
      self.class.allowed_hosts.include?(uri.host)
    end

    def http_uri?(uri)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    end

    def response
      @response ||= make_request
    end

    def make_request
      if method == "get"
        Faraday.get(uri, body)
      else
        Faraday.post(uri, body)
      end
    end
  end
end
