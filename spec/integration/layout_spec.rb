require "capybara/rails"

RSpec.describe "Layout", type: :feature do
  before do
    login_as_admin

    allow(Organisation).to receive(:all).and_return([organisation])
  end

  let(:organisation) { build(:organisation) }

  it "disable Turbo drive by default" do
    visit "/"

    main_wrapper = find(".govuk-main-wrapper")
    expect(main_wrapper.[]("data-turbo")).to eq("false")
  end
end
