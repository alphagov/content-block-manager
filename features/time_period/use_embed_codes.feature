Feature: Editor uses time period embed codes
  - So that I can embed the time period content as needed
  - As an editor looking at a published block
  - I want access to copy codes at the appropriate granularity and I want to
    understand how I can format these elements

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And a published time period content block exists

  Scenario: Copy dates and times in '2025-04-06' and '00:00' format
    Given I am viewing the published edition
    Then I see embed codes for the time period date and time values

  Scenario: Copy default block for '6 April 2025 to 5 April 2026'  format
    Given I am viewing the published edition
    Then I see embed code for the default time period block
