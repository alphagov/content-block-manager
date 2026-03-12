@javascript
Feature: Editor is prompted before they lose their changes
  - As an editor who has spent time and effort inputting data
  - So that I don't lose my work
  - I want to be prompted before I navigate away from a page

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And a pension content block has been drafted

  Scenario: Editing an existing edition and navigating away
    When I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "time_period" schema
    And I fill the form with the following fields:
      | title            | description      | organisation        | instructions_to_publishers |
      | Current Tax Year | Some description | Ministry of Example | This is important          |
    Then I am warned when navigating away
