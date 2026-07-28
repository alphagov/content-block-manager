Feature: Create Time Period Edition
  - So that I can publish a Time Period block
  - As an editor
  - I want to draft a Time Period Edition

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And I am viewing the form to create a new Time Period Edition

  Scenario: Editor can create a new Time Period Edition
    When I fill the Time Period Edition details correctly
    And I save and continue
    Then I see that the Edition was created successfully

  Scenario: Editor is informed when creating a new Time Period Edition incorrectly
    When I fill the Time Period Edition details incorrectly
    And I save and continue
    Then I see which Time Period Edition errors I need to correct
