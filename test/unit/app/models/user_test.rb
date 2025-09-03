require "test_helper"
require "gds-sso/lint/user_test"

class GDS::SSO::Lint::UserTest
  def user_class
    ::User
  end

  setup do
    @lint_user = build(:user)
  end
end

class ContentBlockManager::UserTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "validations" do
    it "validates the presence of a name" do
      user = build(:user, name: nil)

      assert user.invalid?
    end
  end

  describe "#role" do
    it "returns Editor" do
      user = build(:user)

      assert_equal "Editor", user.role
    end
  end
end
