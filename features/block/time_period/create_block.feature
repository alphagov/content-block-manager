Feature: Create "Time period" content block (Block architecture)
  - So that I can publish a block representing a time period
  - As an editor
  - I want to draft the initial block (and edit that draft)

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And I am on the new-style time period form

  Scenario: Editor can create a "Time period" content block
    When I fill the new-style time period form correctly
    And I proceed to add a date range for the new-style Time period
    And I supply the initial new-style time periods correctly
    And I save and continue
    Then I see the initial new-style time period represented clearly

  Scenario: Editor must supply valid edition details
    When I submit the new-style time period form incorrectly
    Then I see the errors messages describing the problems with the new-style edition

  Scenario: Editor must supply valid date range dates
    When I fill the new-style time period form correctly
    And I proceed to add a date range for the new-style Time period
    And I supply an invalid date for the date range
    And I save and continue
    Then I see the error message for the invalid date