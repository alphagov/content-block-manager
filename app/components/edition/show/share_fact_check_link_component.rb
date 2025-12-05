class Edition::Show::ShareFactCheckLinkComponent < ViewComponent::Base
  def initialize(edition:)
    @edition = edition
  end

private

  attr_reader :edition
end
