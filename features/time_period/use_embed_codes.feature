Feature: Editor uses time period embed codes
  - So that I can embed the time period content as needed
  - As an editor looking at a published block
  - I want access to copy codes at the appropriate granularity and I want to
    understand how I can format these elements

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And a published time period content block exists

  Scenario: Copy datetime embed codes for start and end
    Given I am viewing the published edition
    Then I see embed codes for the time period date and time values

  Scenario: Copy default block for '6 April 2025 to 5 April 2026'  format
    Given I am viewing the published edition
    Then I see embed code for the default time period block

  @wip
  Scenario: Copy day of the month e.g. '06'
    # what about formatted day, e.g. '6'?

  @wip
  Scenario: Copy month e.g. '04'
    # what about formatted month, e.g. 'April'

  @wip
  Scenario: Copy year e.g. '2026'
    # what about formatted year e.g. '26', e.g. to construct '2025-26'?