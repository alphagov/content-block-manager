Then("I see a principal call to action of 'Ready for fact check'") do
  expect(page).to have_css(
    "a.govuk-button[href='#{new_review_outcome_edition_path(edition)}']",
    text: I18n.t("show_action.send_to_fact_check"),
  )
end

When("I opt to send the edition to fact check") do
  click_link(I18n.t("show_action.send_to_fact_check"))
end

Then("I am required to provide the outcome of the review process") do
  within "h1" do
    expect(page).to have_content(I18n.t("edition.outcomes.heading.review"))
  end

  within ".govuk-caption-xl" do
    expect(page).to have_content(edition.title)
  end

  expect(page).to have_field(I18n.t("edition.outcomes.options.review.performed"), type: :radio)
  expect(page).to have_field(I18n.t("edition.outcomes.options.review.skip"), type: :radio)
end

When("I provide the outcome of the review process") do
  choose(I18n.t("edition.outcomes.options.review.skip"))
  click_button("Continue")
end

When("I attempt to proceed without supplying the outcome of the review process") do
  click_button("Continue")
end

Then("I see that I need to indicate whether the review process was performed or skipped") do
  expect(page).to have_content("Indicate whether the 2i review process has been performed or not")
  within ".govuk-form-group--error" do
    expect(page).to have_content("Indicate whether the 2i review process has been performed or not")
  end
end

Then("I see a important notice that I should share the fact check link") do
  within ".gem-c-notice" do
    expect(page).to have_content(I18n.t("edition.states.important_notice.awaiting_factcheck"))
  end
end

Given("the edition has been put into the awaiting_factcheck state by another process") do
  # e.g. a race condition...
  edition.update_column(:state, :awaiting_factcheck)
end

def edition
  @edition ||= Edition.last
end
