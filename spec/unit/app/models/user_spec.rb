require "gds-sso/lint/user_test"

class GDS::SSO::Lint::UserTest
  def user_class
    ::User
  end

  setup do
    @lint_user = build(:user)
  end
end

RSpec.describe User do
  describe "validations" do
    it "validates the presence of a name" do
      user = build(:user, name: nil)

      expect(user).to be_invalid
    end
  end

  describe "#role" do
    it "returns Editor" do
      user = build(:user)

      expect(user.role).to eq("Editor")
    end
  end

  describe "#organisation" do
    it "returns nil when organisation_content_id is nil" do
      user = build(:user)

      expect(user.organisation).to be_nil
    end

    it "returns an organisation when one exists" do
      organisation = build(:organisation, id: SecureRandom.uuid)
      user = build(:user, organisation_content_id: organisation.id)

      expect(Organisation).to receive(:find).with(organisation.id).and_return(organisation)

      expect(organisation).to eq(user.organisation)
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

      expect(user1).to be_is_e2e_user
      expect(user2).to be_is_e2e_user
    end
  end
end
