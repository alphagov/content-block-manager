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
