class FakeController < ApplicationController
  include GDS::SSO::ControllerMethods

  prepend_before_action :authenticate_user!

  include ContentBlockManager::AuthenticatesWithJWT

  def fake_action
    head :ok
  end

private

  def block
    @block ||= ContentBlock.from_content_id_alias(params[:id])
  end
end

RSpec.describe FakeController, type: :request do
  let(:user) { create(:user) }
  let(:cookie_jar) { ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash) }
  let(:block) { build(:content_block) }
  let(:path) { "/fake-action/#{block.content_id}" }

  before do
    Rails.application.routes.draw do
      get "/fake-action/:id", to: "fake#fake_action"
    end

    ENV["JWT_AUTH_SECRET"] = "secret"
    allow(ContentBlock).to receive(:from_content_id_alias).and_return(block)
  end

  after do
    Rails.application.reload_routes!
  end

  include_examples "allows authentication with a JWT"
end
