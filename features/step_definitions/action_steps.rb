Then(/I should be able to view the published .+ edition/) do
  within ".actions" do
    expect(page).to have_link("Go to published edition")
  end
  click_link("Go to published edition")
  expect(current_path).to eq(published_edition_document_path(edition.document))
end

Given("I should see the content for the draft contact edition") do
  should_see_the_draft_edition_in_full
end

Given("I should see the content for the published contact edition") do
  should_see_the_published_edition_in_full
end

Then("I see a principal call to action of 'Edit pension'") do
  expect(page).to have_css(
    "a.govuk-button",
    text: "Edit pension",
  )
end

Then("I see a principal call to action to complete the draft") do
  expect(page).to have_css(
    "a.govuk-button",
    text: "Complete draft",
  )
end

Given("I opt to resume editing the draft") do
  click_link("Complete draft")
end

def should_see_the_draft_edition_in_full
  should_see_status_for(state: :draft)
  shows_list_of_locations
  shows_change_history
  shows_details_for_edition_in(state: :draft)
end

def should_see_the_published_edition_in_full
  should_see_status_for(state: :published)
  shows_list_of_locations
  shows_change_history
  shows_details_for_edition_in(state: :published)
end

def shows_list_of_locations
  within "#host_editions" do
    expect(page).to have_content("List of locations")
  end
end

def shows_change_history
  expect(page).to have_css(".timeline")
end

def shows_details_for_edition_in(state:)
  shows_content_in_summary_list_for(state: state)
  shows_content_in_embedded_object_for(state: state)
end

def shows_content_in_summary_list_for(state:)
  within ".gem-c-summary-list" do
    expect(page.html).to include(edition_for(state).render)
  end
end

def shows_content_in_embedded_object_for(state:)
  within ".app-c-embedded-objects-blocks-component" do
    expect(page.html).to include(edition_for(state).render)
  end
end

def edition_for(state)
  return published_edition if state == :published

  draft_edition
end

def published_edition
  @published_edition ||= Edition.last.document.latest_published_edition
end

def draft_edition
  @draft_edition ||= Edition.last.document.most_recent_edition
end
