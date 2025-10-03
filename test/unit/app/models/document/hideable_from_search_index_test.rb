require "test_helper"

class Document::HideableFromSearchIndexTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:user) { create(:user) }

  before do
    Current.stubs(:user).returns(user)
  end

  describe "when a user is an e2e user" do
    before do
      user.stubs(:is_e2e_user?).returns(true)
    end

    it "sets the testing_artefact column to true" do
      document = create(:document)

      assert document.reload.testing_artefact
    end
  end

  describe "when a user is not an e2e user" do
    before do
      user.stubs(:is_e2e_user?).returns(false)
    end

    it "sets the testing_artefact column to false" do
      document = create(:document)

      assert_not document.reload.testing_artefact
    end
  end

  describe "when Current.user is nil" do
    # This should not happen in normal circumstances, but it does happen in tests, so let's ensure we handle it.
    before do
      Current.stubs(:user).returns(nil)
    end

    it "sets the testing_artefact column to false" do
      document = create(:document)

      assert_not document.reload.testing_artefact
    end
  end
end
