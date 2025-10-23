Then(/^I see that the ([^"]*) is Govspeak-enabled$/) do |field|
  id = case field
       when "block description"
         "edition_details_description"

       when "pension rate description"
         "edition_details_rates_description"

       when "contact address description"
         "edition_details_addresses_description"
       when "contact link description"
         "edition_details_contact_links_description"
       when "contact email address description"
         "edition_details_email_addresses_description"
       when "contact telephone description"
         "edition_details_telephones_description"
       when "telephone video relay service source"
         "edition_details_telephones_video_relay_service_source"
       when "telephone bsl guidance value"
         "edition_details_telephones_bsl_guidance_value"
       when "telephone opening hours field"
         "edition_details_telephones_opening_hours_opening_hours"

       else
         raise "Unexpected field name: #{field}"
       end

  expect_to_see_a_govspeak_enabled_textarea_for_id(id)
end

def expect_to_see_a_govspeak_enabled_textarea_for_id(id)
  assert(
    page.has_selector?(".app-c-govspeak-editor ##{id}"),
    "Expected to find Govspeak-enabled textarea with ID '##{id}'",
  )
end
