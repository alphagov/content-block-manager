module Services
  def self.signon_api_client
    GdsApi::SignonApi.new(
      Plek.find("signon", external: true),
      bearer_token: ENV.fetch("SIGNON_API_BEARER_TOKEN", "example"),
    )
  end
end
