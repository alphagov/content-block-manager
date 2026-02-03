class Edition::Show::ShareFactCheckLinkComponent < ViewComponent::Base
  def initialize(edition:, open: false)
    @edition = edition
    @open = open
  end

private

  attr_reader :edition, :open

  def formatted_expiration_timestamp
    edition.bypass_token_expiry_date.to_fs(:long_ordinal_with_at)
  end
end
