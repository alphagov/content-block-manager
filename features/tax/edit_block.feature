@javascript
Feature: Edit Tax Content Block

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And the schema "tax" exists
    And a tax content block has been created
    And dependent content exists for a content block

  Scenario: GDS Editor edits a tax object
    When I visit the Content Block Manager home page
    And I click to view the document
    And I click to edit the "tax"
    When I fill out the form
    Then I should be on the "review_links" step
    And I should see a back link to the "edit_draft" step
    And there should be no accessibility errors
    When I continue after reviewing the links
    Then I should be on the "internal_note" step
    And I should see a back link to the "review_links" step
    And there should be no accessibility errors
    When I add an internal note
    Then I should be on the "change_note" step
    And I should see a back link to the "internal_note" step
    And there should be no accessibility errors
    When I add a change note
    Then I should be on the "schedule_publishing" step
    And I should see a back link to the "change_note" step
    And there should be no accessibility errors
    When I choose to publish the change now
    Then I should be on the "review" step
    And I should see a back link to the "schedule_publishing" step
    And there should be no accessibility errors
    Then I should see a button labelled "Publish"
    And I should not see a preview button
    When I review and confirm I have checked the content
    Then I should be taken to the confirmation page for a published block
    And there should be no accessibility errors
    When I click to view the content block
    Then the edition should have been updated successfully
