@wip
Feature: Create "Time period" content block (Block architecture)
  - So that I can publish a block representing a time period
  - As an editor
  - I want to draft the initial block (and edit that draft)

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And I am on the new-style time period form

  Scenario: Editor can create a "Time period" content block
    When I fill the form with the following fields:
      | title            | description      | organisation        | instructions_to_publishers |
      | Current Tax Year | Some description | Ministry of Example | This is important          |
    And I proceed to add a date range for the Time period
    And I supply the initial time periods correctly
    And I save and continue
    Then I see the initial time period represented clearly

    When I review and confirm I have checked the content
    Then I should be taken to the confirmation page
    And the block should have been sent to the Publishing API
    When I click to view the content block
    Then I should see the details for the time_period content block

  Scenario: Time period validates correctly
    When I fill the form with the following fields:
      | title            | description      | organisation        | instructions_to_publishers |
      | Current Tax Year | Some description | Ministry of Example | This is important          |
    And I proceed to add a date range for the Time period
    When I supply the time periods with the end date before the start date
    And I save and continue
    Then I should see an error message telling me that the end date cannot be before the start date

  Scenario: Editor can edit a draft time period block
    Given a draft time period block exists
    When I am viewing the draft edition
    And I edit the draft time period block
    And I confirm I have checked the content
    Then I should see the edited time period values have been saved

  Scenario: Editor can view a draft time period before date range added
    Given a draft time period block exists without a date range
    When I am viewing the draft edition
    Then I should see the description of the time period block
    And the default block should not be shown
    And the time period's date range block should not be shown
