require "test_helper"
require "capybara/rails"

class Admin::LayoutTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL

  setup do
    login_as_admin

    Organisation.stubs(:all).returns([organisation])
  end

  let(:organisation) { build(:organisation) }

  it "disable Turbo drive by default" do
    visit "/"

    main_wrapper = find(".govuk-main-wrapper")
    assert_equal("false", main_wrapper["data-turbo"])
  end
end
