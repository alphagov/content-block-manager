Then("the default block should not be shown") do
  expect(page).not_to have_css(".app-c-content-block-manager-default-block")
end
