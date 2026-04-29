Then("I see a principal call to action of 'Publish block'") do
  expect(page).to have_css(
    "a.govuk-button[href='#{new_fact_check_outcome_edition_path(edition)}']",
    text: "Publish block",
  )
end

When("I opt to complete the fact check process") do
  click_link "Publish block"
end

Then("I am required to provide the outcome of the fact check process") do
  within "h1" do
    expect(page).to have_content(I18n.t("edition.outcomes.heading.fact_check"))
  end

  within ".govuk-caption-xl" do
    expect(page).to have_content(edition.title)
  end

  expect(page).to have_field(I18n.t("edition.outcomes.options.fact_check.performed"), type: :radio)
  expect(page).to have_field(I18n.t("edition.outcomes.options.fact_check.skip"), type: :radio)
end

When("I provide the outcome of the fact check process") do
  choose(I18n.t("edition.outcomes.options.fact_check.performed"))
end

Then("I am required to provide the subject matter expert") do
  expect(page).to have_field(I18n.t("edition.outcomes.performer.label.fact_check"), type: :text)
end

When("I provide the subject matter expert") do
  @fact_checker = "Jane Doe"
  fill_in I18n.t("edition.outcomes.performer.label.fact_check"), with: @fact_checker
  click_button("Publish")
end

When("I attempt to proceed without supplying the outcome of the fact check process") do
  click_button("Continue")
end

Then("I see that I need to indicate whether the fact check process was performed or skipped") do
  expect(page).to have_content(I18n.t("edition.outcomes.errors.missing_outcome.fact_check"))
  within ".govuk-form-group--error" do
    expect(page).to have_content(I18n.t("edition.outcomes.errors.missing_outcome.fact_check"))
  end
end

Given("the edition has been put into the published state by another process") do
  # e.g. a race condition...
  edition.update_column(:state, :published)
end

Then("a domain event for the fact check should have been created") do
  domain_event = edition.domain_events.where(name: "edition.fact_check.performed").last
  expect(domain_event).to be_present
  expect(domain_event.metadata).to eq({ "performer" => @fact_checker })
end
