Feature: Edit published time period block to create a new edition
  - So that I can make changes to a published time period block
  - As an editor
  - I want to "edit" the block and draft a further edition

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And the local schema "time_period" exists
    And a published time period content block exists

  Scenario:
    When I visit the Content Block Manager home page
    And I click to view the document
    And I click to edit the "time period"
    And I fill the form with the following fields:
    | title         |
    | Changed title |
    And I supply the changed values of the time period
    And I save and continue
    Then I should be able to complete all the steps in the workflow for a further edition
    Then I should see a button labelled "Publish"
    When I review and confirm I have checked the content
    Then I should be taken to the confirmation page for a published block
    When I click to view the content block
    Then the edition should have been updated successfully
    And I should see the changed values of the new edition