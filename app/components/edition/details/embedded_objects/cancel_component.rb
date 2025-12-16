class Edition::Details::EmbeddedObjects::CancelComponent < ViewComponent::Base
  def initialize(edition:, subschema:, redirect_url: nil)
    @edition = edition
    @subschema = subschema
    @redirect_url = redirect_url
  end

  attr_reader :edition, :redirect_url, :subschema
end
