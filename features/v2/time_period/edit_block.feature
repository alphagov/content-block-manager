Feature: Edit Time Period Edition
  - So that I can fix or update a Time Period block
  - As an editor
  - I want to edit a Time Period Edition

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And a Time Period Edition exists
    And I am viewing the form to update an existing Time Period Edition

  Scenario: Editor can return to edit time period edition metadata page
    Given I am viewing the pre publication review page
    When I follow the link to edit the time period details
    Then I see the edit time period page

  Scenario: Editor can edit an existing Time Period Edition
    When I fill the Time Period Edition details correctly
    And I save and continue
    Then I see the pre publication review page
    And I see that the Edition was updated successfully

  Scenario: Editor is informed when editing an existing Time Period Edition incorrectly
    When I fill the Time Period Edition details incorrectly
    And I save and continue
    Then I see which Time Period Edition errors I need to correct

  Scenario: Editor can return to edit time period date range page
    Given I am viewing the pre publication review page
    When I follow the link to edit the date range
    Then I see the edit date range page

  Scenario: Editor can edit time period date range page
    Given I am on the edit date range page
    When I fill the date range details correctly
    And I save and continue
    Then I see the pre publication review page
    And I see a notice that the update was successful
