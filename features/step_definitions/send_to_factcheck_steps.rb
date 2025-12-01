Then("I see a principal call to action of 'Send to factcheck'") do
  expect(page).to have_css(
    "a.govuk-button[href='#{new_review_outcome_path(edition)}']",
    text: "Send to factcheck",
  )
end

When("I opt to send the edition to factcheck") do
  click_link("Send to factcheck")
end

Then("I am required to provide the outcome of the review process") do
  within "h1" do
    expect(page).to have_content("Ready for factcheck")
  end

  within ".govuk-caption-xl" do
    expect(page).to have_content(edition.title)
  end

  expect(page).to have_field("Completed 2i review", type: :radio)
  expect(page).to have_field("Skip 2i review", type: :radio)
end

When("I provide the outcome of the review process") do
  choose("Skip 2i review")
  click_button("Continue")
end

When("I attempt to proceed without supplying the outcome of the review process") do
  click_button("Continue")
end

Then("I see that I need to indicate whether the review process was performed or skipped") do
  expect(page).to have_content("Indicate whether the 2i Review process has been performed or not")
  within ".govuk-form-group--error" do
    expect(page).to have_content("Describe the outcome of the 2i process")
  end
end

Given("the edition has been put into the awaiting_factcheck state by another process") do
  # e.g. a race condition...
  edition.update_column(:state, :awaiting_factcheck)
end

def edition
  @edition ||= Edition.last
end
