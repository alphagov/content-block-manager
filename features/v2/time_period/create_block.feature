Feature: Create Time Period Edition
  - So that I can publish a Time Period block
  - As an editor
  - I want to draft a Time Period Edition

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And I visit the content block list page
    And I follow the link to create a new content block
    And I select "Time period"
    And I save and continue
    Then I am viewing the form to create a new Time Period Edition

  Scenario: Editor can create a new Time Period Edition
    When I fill the Time Period Edition details correctly
    And I continue to the date range page
    And I fill the date range details correctly
    And I save and continue
    Then I see the pre publication review page
    And I see that the Edition was created successfully

  Scenario: Editor can navigate back to the select content block type page
    When I click the back link
    Then I see the select content block type page

  Scenario: Editor can cancel creation to return to the select content block type page
    When I click the cancel link
    Then I see the select content block type page

  Scenario: Editor is informed when creating a new Time Period Edition incorrectly
    When I fill the Time Period Edition details incorrectly
    And I save and continue
    Then I see which Time Period Edition errors I need to correct

  Scenario: Editor is informed when creating a date range incorrectly
    When I fill the Time Period Edition details correctly
    And I continue to the date range page
    And I save and continue
    Then I see errors telling me to enter values