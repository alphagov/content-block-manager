Feature: Create a pension block

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And the schema "pension" exists

  Scenario: GDS editor creates a Pension without a rate
    When I visit the Content Block Manager home page
    And I click to create an object
    Then I should see all the schemas listed
    When I click on the "pension" schema
    Then I should see a form for the schema
    When I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic pension | this is basic | Ministry of Example | this is important  |
    Then I should be on the "add_embedded_rates" step
    When I save and continue
    Then I am asked to review my answers for a "pension"
    And I should see a button labelled "Create"
    And I should not see a preview button
    And I review and confirm I have checked the content
    Then the edition should have been created successfully
    And I should be taken to the confirmation page for a new "pension"

  @javascript
  Scenario: GDS editor creates a Pension with a rate
    When I visit the Content Block Manager home page
    And I click to create an object
    Then I should see all the schemas listed
    And there should be no accessibility errors
    When I click on the "pension" schema
    Then I should see a form for the schema
    And there should be no accessibility errors
    When I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic pension | this is basic | Ministry of Example | this is important  |
    Then there should be no accessibility errors
    When I click to add a new "rate"
    Then I should see a back link to the "embedded_rates" step
    And there should be no accessibility errors
    And I complete the "rate" form with the following fields:
      | title    | amount  | frequency |
      | New rate | £127.91 | a month  |
    Then I should be on the "add_embedded_rates" step
    When I save and continue
    Then there should be no accessibility errors
    And I review and confirm I have checked the content
    Then I should be taken to the confirmation page for a new "pension"
    And analytics messages should have been sent for each step in the workflow
    And analytics messages should have been sent for each embedded object
    And there should be no accessibility errors

  Scenario: GDS editor creates a Pension and cancels on the first rate
    When I visit the Content Block Manager home page
    And I click to create an object
    Then I should see all the schemas listed
    When I click on the "pension" schema
    Then I should see a form for the schema
    When I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic pension | this is basic | Ministry of Example | this is important  |
    When I click to add a new "rate"
    And I click the cancel link
    Then I should be on the "add_embedded_rates" step

  Scenario: GDS editor creates a Pension and sees validation errors for new rate
    When I visit the Content Block Manager home page
    And I click to create an object
    When I click on the "pension" schema
    When I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic pension | this is basic | Ministry of Example | this is important  |
    When I click to add a new "rate"
    And I click save
    Then I should see errors for the required "rate" fields
    And I should see a back link to the "embedded_rates" step

  Scenario: GDS editor clicks back and is taken back to rates
    When I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "pension" schema
    Then I should see a title for the create flow
    When I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic pension | this is basic | Ministry of Example | this is important  |
    And I click the back link
    And I click save
    Then I should be on the "add_embedded_rates" step

  Scenario: Block editor sees expected Govspeak-enabled fields
    When I am creating a pension content block
    Then I see that the block description is Govspeak-enabled
    When I am creating a pension rate
    Then I see that the pension rate description is Govspeak-enabled

