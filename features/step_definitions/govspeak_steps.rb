Then("I see that the block description is Govspeak-enabled") do
  expect_to_see_a_govspeak_enabled_textarea_for_id("edition_details_description")
end

Then("I see that the pension rate description is Govspeak-enabled") do
  expect_to_see_a_govspeak_enabled_textarea_for_id("edition_details_rates_description")
end

def expect_to_see_a_govspeak_enabled_textarea_for_id(id)
  assert(
    page.has_selector?(".app-c-govspeak-editor ##{id}"),
    "Expected to find Govspeak-enabled textarea with ID '##{id}'",
  )
end
