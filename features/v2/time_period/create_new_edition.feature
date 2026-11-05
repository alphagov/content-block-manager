Feature: Create Time Period Edition
  - As an editor
  - I want to create a new Time Period Edition for a given document
  - So that I can update the content block without changing the embed codes in use in content

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And a Time Period Edition exists
    And that edition is published
    And I am viewing the show document page for that time period
    Then I click the link to Edit Time Period

  Scenario: Editor can create a new Time Period Edition
    When I see the Time Period Edition fields pre-populated with the existing edition's data
    And I update the edition title to "Updated edition title"
    And I continue to the date range page
    Then I see the Time Period Date Range fields pre-populated with the existing date range's data
    When I update the year for the date range to 2026-2027
    And I save and continue
    Then I see the pre publication review page
    And I see that the Edition was created successfully
    And I see that the document's edition and date range have been updated with the details that I entered

  Scenario: Editor can navigate back to the document show page
    When I click the back link
    Then I see the Show page for "New Time Period Edition"

  Scenario: Editor can cancel creation to return to the document show page
    When I click the cancel link
    Then I see the Show page for "New Time Period Edition"

  Scenario: Editor is informed when creating a new Time Period Edition incorrectly
    When I fill the Time Period Edition details incorrectly
    And I save and continue
    Then I see which Time Period Edition errors I need to correct

  Scenario: Editor is informed when creating a date range incorrectly
    When I fill the Time Period Edition details correctly
    And I continue to the date range page
    And I fill the Time Period Date Range details with invalid data
    And I save and continue
    Then I see errors telling me I have not entered valid dates
