module Edition::HasAuthBypassToken
  extend ActiveSupport::Concern

  included do
    before_create :set_auth_bypass_id
  end

  def set_auth_bypass_id
    self.auth_bypass_id = SecureRandom.uuid
  end
end
