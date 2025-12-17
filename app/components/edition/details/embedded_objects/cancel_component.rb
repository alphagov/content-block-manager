class Edition::Details::EmbeddedObjects::CancelComponent < ViewComponent::Base
  def initialize(back_link:, redirect_url: nil)
    @back_link = back_link
    @redirect_url = redirect_url
  end

  attr_reader :back_link, :redirect_url
end
