class FactCheck::BlocksController < FactCheck::ApplicationController
  skip_before_action :authenticate_user!, if: :has_valid_jwt?

  def show
    @block = block
  end

private

  def has_valid_jwt?
    jwt_payload["sub"] == block.auth_bypass_id
  end

  def jwt_payload
    JWT.decode(params[:token], ENV["JWT_AUTH_SECRET"], true, { algorithm: "HS256" }).first
  rescue JWT::DecodeError
    {}
  end

  def block
    @block ||= ContentBlock.from_content_id_alias(params[:id])
  end
end
