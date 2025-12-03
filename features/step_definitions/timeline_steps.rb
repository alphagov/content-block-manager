Then("I should see the contact created event on the timeline") do
  expect(page).to have_selector(".timeline__title", text: "Contact created")
  expect(page).to have_selector(".timeline__byline", text: "by #{@user.name}")
end

Then(/^I should see ([^"]*) publish events on the timeline$/) do |count|
  expect(page).to have_selector(".timeline__title", text: "Published", count:)
end

Then("I should see the notes on the timeline") do
  expect(page).to have_selector("p", text: @internal_note)
  expect(page).to have_selector("p", text: @change_note)
end

Then("I should see the publish event on the timeline") do
  expect(page).to have_selector(".timeline__title", text: "Published")
  expect(page).to have_selector(".timeline__byline", text: "by Scheduled Publishing Robot")
end

Then("I should see the scheduled event on the timeline") do
  expect(page).to have_selector(".timeline__title", text: "Scheduled")
  expect(page).to have_selector(".timeline__byline", text: "by #{@user.name}")
end

Then(/I see the transition to the ([^"]*) state in the timeline/) do |state|
  timeline_title = case state
                   when "awaiting_review"
                     "Sent to review"
                   when "awaiting_factcheck"
                     "Sent to factcheck"
                   else
                     "Pension #{state}"
                   end
  within ".timeline__item:first" do
    expect(page).to have_selector(".timeline__title", text: timeline_title)
    expect(page).to have_selector(".timeline__byline", text: "by #{@user.name}")
  end
end

Then("I see the details of the review outcome in the timeline") do
  skipped_or_performed = edition.reload.review_skipped ? "skipped" : "performed"
  within ".timeline__item:first" do
    expect(page).to have_content("2i review #{skipped_or_performed}")
  end
end

And("I should see the edition diff in a table") do
  expect(page).to have_selector(".govuk-table__cell", text: "Changed title")
  expect(page).to have_selector(".govuk-table__cell", text: @content_block.document.title)
end
