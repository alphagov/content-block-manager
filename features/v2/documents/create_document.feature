Feature: Create new document
  - So that I can publish a content block
  - As an editor
  - I want to select a block type

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And I visit the content block list page
    And I follow the link to create a new content block
    Then I see the select content block type page

Scenario: Editor can select a block type
    When I select "Time period"
    And I save and continue
    Then I am viewing the form to create a new Time Period Edition

Scenario: Editor can't proceed without selecting a block type
    When I save and continue
    Then I see an error telling me to select a block type