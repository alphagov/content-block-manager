Given("the disable_block_creation flag is enabled") do
  test_strategy = Flipflop::FeatureSet.current.test!
  test_strategy.switch!(:disable_block_creation, true)
end

Given("the disable_block_creation flag is disabled") do
  test_strategy = Flipflop::FeatureSet.current.test!
  test_strategy.switch!(:disable_block_creation, false)
end

Then("I should not have the ability to create blocks") do
  expect(page).not_to have_link("Create content block")
end

Then("I should have the ability to create blocks") do
  expect(page).to have_link("Create content block")
end

Then("I should see a notice explaining why block creation is disabled") do
  expect(page).to have_css(
    ".govuk-notification-banner",
    text: "Block creation is currently disabled",
  )
end

Then("I should not see a notice explaining that block creation is disabled") do
  expect(page).not_to have_css(
    ".govuk-notification-banner",
    text: "Block creation is currently disabled",
  )
end
