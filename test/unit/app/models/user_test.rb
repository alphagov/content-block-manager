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

class UserTest < ActiveSupport::TestCase
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

  describe "#organisation" do
    it "returns nil when organisation_content_id is nil" do
      user = build(:user)

      assert_nil user.organisation
    end

    it "returns an organisation when one exists" do
      organisation = build(:organisation, id: SecureRandom.uuid)
      user = build(:user, organisation_content_id: organisation.id)

      Organisation.expects(:find).with(organisation.id).returns(organisation)

      assert_equal user.organisation, organisation
    end
  end

  describe "#is_e2e_user?" do
    let(:e2e_emails) { "e2euser@example.com,anothere2e@example.com" }

    around do |test|
      ClimateControl.modify E2E_USER_EMAILS: e2e_emails do
        test.call
      end
    end

    it "returns false when the user's email address is not included in the E2E_USER_EMAILS environment variable" do
      user = build(:user, email: "normaluser@example.com")

      assert_not user.is_e2e_user?
    end

    it "returns true when the user's email address is included in the E2E_USER_EMAILS environment variable" do
      user1 = build(:user, email: "e2euser@example.com")
      user2 = build(:user, email: "anothere2e@example.com")

      assert user1.is_e2e_user?
      assert user2.is_e2e_user?
    end
  end
end
