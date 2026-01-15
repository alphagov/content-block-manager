Feature: Delete a content object

  Background:
    Given I am logged in
    And I have the "pre_release_features" permission
    And the organisation "Ministry of Example" exists
    And the schema "pension" exists

  Scenario: GDS editor creates a Pension and deletes it
    Given a pension content block has been drafted

    When I am viewing the draft edition
    And I click the link to go to the delete page
    And I click the button to delete
    Then I see a notification that the transition to deleted was successful
    When I visit the Content Block Manager home page
    Then I should not see the content block listed

  Scenario: GDS editor creates an edition for an existing block and deletes it
    Given a pension content block has been created
    And a pension content block has been drafted

    When I am viewing the draft edition
    And I click the link to go to the delete page
    And I click the button to delete
    Then I see a notification that the transition to deleted was successful

    When I visit the Content Block Manager home page
    Then I should see the content block listed
    And the content block should have the tag "Published"

