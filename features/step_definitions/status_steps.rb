Then("I should see the status of the latest edition of the block") do
  edition = @content_block.document.editions.last
  should_show_the_status_for(edition: edition)
end

def should_show_the_status_for(edition:)
  should_see_status_for(state: edition.state)
end

Then(/I see that the edition is in ([^"]*) state/) do |state|
  should_see_status_for(state: state)
end

def should_see_status_for(state:)
  translated_state = I18n.t("edition.states.label.#{state}")

  within ".govuk-tag[title='Status: #{translated_state}']" do
    expect(page).to have_content(translated_state)
  end
end

Then(/I see a notification that the transition to ([^"]*) was successful/) do |state|
  message = "Edition has been moved into state '#{state}'"

  within(".govuk-notification-banner--success") do
    expect(page).to have_content(message)
  end
end

Then(/I see an alert that the transition failed to transition to ([^"]*)/) do |state|
  raise "Only the 'awaiting_review' state is supported currently" unless state == "awaiting_review"

  message = "Error: we can not change the status of this edition."
  error_details = "Can't fire event `ready_for_review` in current state `awaiting_review`"

  within(".gem-c-error-alert__message") do
    expect(page).to have_content(message)
    expect(page).to have_content(error_details)
  end
end

Then(/the calls to action are suited to the ([^"]*) state/) do |state|
  raise "Only the 'awaiting_review' state is supported currently" unless state == "awaiting_review"

  within ".actions" do
    expect(page).to have_link("Edit pension")
    expect(page).to have_no_button("Send to 2i")
  end
end
