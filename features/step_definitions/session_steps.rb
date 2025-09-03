Given("I am logged in") do
  @user = create(:user)
  @user.save!
  login_as @user
end

Given(/^I have the "(.*?)" permission$/) do |perm|
  @user.permissions << perm
  @user.save!
end

Around("@use_real_sso") do |_scenario, block|
  current_sso_env = ENV["GDS_SSO_MOCK_INVALID"]
  ENV["GDS_SSO_MOCK_INVALID"] = "1"
  block.call
  ENV["GDS_SSO_MOCK_INVALID"] = current_sso_env
end
