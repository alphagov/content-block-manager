class Edition::Show::ShareFactCheckLinkComponent < ViewComponent::Base
  def initialize(edition:, open: false)
    @edition = edition
    @open = open
  end

private

  attr_reader :edition, :open
end
