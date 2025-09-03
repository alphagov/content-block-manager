require "test_helper"

class Admin::PreviewControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  view_test "renders the body param using govspeak into a document body template" do
    post :preview, params: { body: "# gov speak" }
    assert_select ".document .body h1", "gov speak"
  end

  test "preview returns a 403 if the content contains potential XSS exploits" do
    post :preview, params: { body: "<script>alert('woah');</script>" }
    assert_response :forbidden
  end
end
