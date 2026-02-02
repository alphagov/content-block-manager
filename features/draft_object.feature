Feature: Drafting a content block

  Background:
    Given I am logged in
    # temporary until we release this feature:
    And I have the "pre_release_features" permission
    And the organisation "Ministry of Example" exists
    And the schema "pension" exists
    And the schema "contact" exists
    And I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "pension" schema
    And I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic pension | this is basic | Ministry of Example | this is important  |

  Scenario: GDS editor cancels the creation of an object
    And I click the cancel link
    And I choose to delete the in-progress draft
    Then I am taken back to Content Block Manager home page
    And no draft Content Block Edition has been created
    And no draft Content Block Document has been created

  Scenario: Draft documents are listed
    And I visit the Content Block Manager home page
    Then I should see the draft document

  Scenario: GDS editor saves their edition as a draft
    When I proceed without adding a rate
    And I save a draft
    Then I should be taken back to the document page
    And I should see a notice that the completed drafted has been saved
    And the draft state of the object should be shown
    When I return to the homepage
    Then I should see the content block with title "my basic pension" returned
    And I should see a tag containing "Draft"

  Scenario: Editor can not send an incomplete draft to review
    Given I am viewing the draft edition
    And the draft workflow has not been completed
    Then I do not see a call to action of 'Ready for 2i'
    And I see a principal call to action to complete the draft

  @javascript
  Scenario: Editor does not see embed code for default contact block when draft
    Given a draft contact edition exists
    And I am viewing the draft edition
    Then I do not see the facility to copy the embed code
    And I should not see the contact default block embed code displayed

  @javascript
  Scenario: Editor does not see embed code for a specific field when draft
    Given the pension has a rate set
    And I am viewing the draft edition
    Then I do not see the facility to copy the embed code
    And I should not see the pension rate embed code displayed

  Scenario: Editor without javascript does not see embed code when draft
    Given the pension has a rate set
    And I am viewing the draft edition
    Then I should not see the pension rate embed code displayed
