Feature: Create "Time period" content block
  - So that I can publish a block representing a time perio
  - As an editor
  - I want to draft the initial block (and edit that draft)

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And the local schema "time_period" exists
    And I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "time_period" schema

  Scenario: Editor can create a "Time period" content block
    When I fill the form with the following fields:
      | title            | note      | description      | organisation        | instructions_to_publishers |
      | Current Tax Year | Some note | Some description | Ministry of Example | This is important          |
    And I supply the time periods correctly
    And I save and continue
    And I review and confirm I have checked the content
    Then I should be taken to the confirmation page
    And the block should have been sent to the Publishing API
    When I click to view the content block
    Then I should see the details for the time_period content block

  Scenario: Editor can edit a draft time period block
    Given a draft time period block exists
    When I am viewing the draft edition
    And I edit the draft time period block
    And I confirm I have checked the content
    Then I should see the edited time period values have been saved

