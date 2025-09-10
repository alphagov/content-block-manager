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
end
