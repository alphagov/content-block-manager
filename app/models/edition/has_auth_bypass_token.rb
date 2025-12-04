module Edition::HasAuthBypassToken
  extend ActiveSupport::Concern

  included do
    before_create :set_auth_bypass_id
  end

  def set_auth_bypass_id
    self.auth_bypass_id = SecureRandom.uuid
  end

  def auth_bypass_token
    JWT.encode(
      {
        "sub" => auth_bypass_id,
        "content_id" => content_id,
        "iat" => Time.zone.now.to_i,
        "exp" => bypass_token_expiry_date.to_i,
      },
      ENV["JWT_AUTH_SECRET"],
      "HS256",
    )
  end

  def bypass_token_expiry_date
    1.month.from_now
  end
end
