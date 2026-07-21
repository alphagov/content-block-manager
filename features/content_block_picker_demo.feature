Feature: Content Block Picker Demo
  As a developer
  I want to test the content block picker demo page
  So that I can ensure the picker library loads and functions correctly

  Background:
    Given I am logged in

  @javascript
  Scenario: Demo page loads with correct layout
    When I visit the Content Block Picker Demo page
    Then I should see the heading "Content Block Picker Demo"
    And I should see the demo textarea
    And I should see the 'Insert block' button
    And the content block picker CSS should be loaded

  @javascript
  Scenario: Content block picker JavaScript library loads correctly
    When I visit the Content Block Picker Demo page
    Then the content block picker should be initialized on the textarea
    And there should be no JavaScript errors