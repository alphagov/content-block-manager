Feature: Create Time Period Edition
  - So that I can publish a Time Period block
  - As an editor
  - I want to review a Time Period Edition

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And a Time Period Edition exists
    And a date range exists for that time period
    And I am viewing the pre publication review page

  Scenario: Editor can review a new Time Period Edition
    When I confirm that the block details are correct and continue
    Then I see the content block list page
    And I see that the edition was published successfully

