require "capybara/rails"

RSpec.describe ErrorsController, type: :request do
  before do
    login_as_admin
  end

  error_codes = {
    "400": :bad_request,
    "403": :forbidden,
    "404": :not_found,
    "422": :unprocessable_content,
    "500": :internal_server_error,
  }.freeze

  error_codes.each do |error_code, error|
    it "should show the #{error} page" do
      get "/#{error_code}"

      assert_template error
    end
  end
end
