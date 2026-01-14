Given("I indicate that the video relay service info should be displayed") do
  check label_for("show")
end

Given("I provide custom video relay service info where available") do
  within("#edition_details_telephones_video_relay_service_show") do
    fill_in(label_for("label"), with: "Custom label")
    fill_in(label_for("telephone_number"), with: "01777 123 1234")
    fill_in(label_for("source"), with: "[Custom source](www.example.com)")
    should_be_able_to_preview_the_govspeak_enabled_field
  end
end

When("I should see that the video relay service info has been changed") do
  within(".gem-c-summary-card[title='#{I18n.t('edition.titles.contact.telephones.video_relay_service')}']") do
    expect(page).to have_no_css("dt", text: I18n.t("edition.labels.contact.telephones.video_relay_service.show"))
    expect(page).to have_no_css("dt", text: "Yes")

    expect(page).to have_content("01777 123 1234")
    expect(page).to have_content("Custom label")
    expect(page).to have_link("Custom source", href: "www.example.com")
  end
end

def label_for(field_name)
  I18n.t("edition.labels.contact.telephones.video_relay_service.#{field_name}")
end

def should_be_able_to_preview_the_govspeak_enabled_field
  click_button("Preview")
  preliminary_preview_text = page.find(".app-c-govspeak-editor__preview p").text

  assert_equal(
    "Generating preview, please wait.",
    preliminary_preview_text,
  )
end
