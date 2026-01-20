Then("I see a principal call to action of 'Publish block'") do
  expect(page).to have_css(
    "a.govuk-button[href='#{new_factcheck_outcome_edition_path(edition)}']",
    text: "Publish block",
  )
end

When("I opt to complete the factcheck process") do
  click_link "Publish block"
end

Then("I am required to provide the outcome of the factcheck process") do
  within "h1" do
    expect(page).to have_content("Publish block")
  end

  within ".govuk-caption-xl" do
    expect(page).to have_content(edition.title)
  end

  expect(page).to have_field("Completed factcheck", type: :radio)
  expect(page).to have_field("Skip factcheck", type: :radio)
end

When("I provide the outcome of the factcheck process") do
  choose("Completed factcheck")
  click_button("Continue")
end

Then("I am required to provide the subject matter expert") do
  within "h1" do
    expect(page).to have_content("Publish block")
  end

  within ".govuk-caption-xl" do
    expect(page).to have_content(edition.title)
  end

  expect(page).to have_field(I18n.t("edition.outcomes.performer.label.factcheck"), type: :text)
end

When("I provide the subject matter expert") do
  fill_in I18n.t("edition.outcomes.performer.label.factcheck"), with: "Jane Doe"
  click_button("Publish")
end

When("I attempt to proceed without supplying the outcome of the factcheck process") do
  click_button("Continue")
end

Then("I see that I need to indicate whether the factcheck process was performed or skipped") do
  expect(page).to have_content(I18n.t("edition.outcomes.errors.missing_outcome.factcheck"))
  within ".govuk-form-group--error" do
    expect(page).to have_content(I18n.t("edition.outcomes.errors.missing_outcome.factcheck"))
  end
end

Given("the edition has been put into the published state by another process") do
  # e.g. a race condition...
  edition.update_column(:state, :published)
end
