require_relative "../support/axe_results"

Then(/^there should be no accessibility errors$/) do
  # Ignore `aria-allowed-attr` violation for conditional reveal radio buttons (https://github.com/alphagov/govuk-frontend/issues/979)
  exclusions = [
    AxeResults::ExclusionRule.new(id: "aria-allowed-attr", selector: ".govuk-radios__input"),
  ]
  results = AxeResults.new(page, exclusions:)
  assert_empty results.violations
end
