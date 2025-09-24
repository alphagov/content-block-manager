Then("I see that the block description is Govspeak-enabled") do
  expect_to_see_a_govspeak_enabled_textarea_for_id("edition_details_description")
end

Then("I see that the pension rate description is Govspeak-enabled") do
  expect_to_see_a_govspeak_enabled_textarea_for_id("edition_details_rates_description")
end

Then("I see that the contact address description is Govspeak-enabled") do
  expect_to_see_a_govspeak_enabled_textarea_for_id("edition_details_addresses_description")
end

Then("I see that the contact link description is Govspeak-enabled") do
  expect_to_see_a_govspeak_enabled_textarea_for_id("edition_details_contact_links_description")
end

Then("I see that the contact email address description is Govspeak-enabled") do
  expect_to_see_a_govspeak_enabled_textarea_for_id("edition_details_email_addresses_description")
end

Then("I see that the contact telephone description is Govspeak-enabled") do
  expect_to_see_a_govspeak_enabled_textarea_for_id("edition_details_telephones_description")
end

Then("I see that the telephone video relay service prefix is Govspeak-enabled") do
  expect_to_see_a_govspeak_enabled_textarea_for_id("edition_details_telephones_video_relay_service_prefix")
end

Then("I see that the telephone bsl guidance value is Govspeak-enabled") do
  expect_to_see_a_govspeak_enabled_textarea_for_id("edition_details_telephones_bsl_guidance_value")
end

def expect_to_see_a_govspeak_enabled_textarea_for_id(id)
  assert(
    page.has_selector?(".app-c-govspeak-editor ##{id}"),
    "Expected to find Govspeak-enabled textarea with ID '##{id}'",
  )
end
