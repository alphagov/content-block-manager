require "capybara/rails"

RSpec.describe "Users", type: :feature do
  include Rails.application.routes.url_helpers

  before do
    logout
    user = create(:user)
    login_as(user)
  end

  describe "#show" do
    let(:user_uuid) { SecureRandom.uuid }

    scenario "returns 404 if the user doesn't exist" do
      expect(SignonUser).to receive(:with_uuids).with([user_uuid]).and_return([])
      visit user_path(user_uuid)
      assert_text "Could not find User with ID #{user_uuid}"
    end
  end
end
