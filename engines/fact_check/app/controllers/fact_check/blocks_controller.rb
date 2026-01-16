require "nokodiff"

class FactCheck::BlocksController < FactCheck::ApplicationController
  skip_before_action :authenticate_user!, if: :has_valid_jwt?
  before_action :set_jwt_cookie, if: :has_valid_jwt?

  def show
    @block = block
    @document = Document.find(params[:id])
    @current_edition = @document.most_recent_edition
    @published_edition = @document.latest_published_edition
    @schema = Schema.find_by_block_type(@document.block_type)
  end

private

  def has_valid_jwt?
    jwt_payload["sub"] == block.auth_bypass_id
  end

  def set_jwt_cookie
    cookies.signed[:token] ||= token
  end

  def jwt_payload
    JWT.decode(token, ENV["JWT_AUTH_SECRET"], true, { algorithm: "HS256" }).first
  rescue JWT::DecodeError
    {}
  end

  def block
    @block ||= ContentBlock.from_content_id_alias(params[:id])
  end

  def token
    params[:token] || cookies.signed[:token]
  end
end
