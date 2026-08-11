Feature: Search for a content object
  Background:
    Given I am logged in
    And the organisation "Department of Placeholder" exists
    And the organisation "Ministry of Example" exists
    And the following time period content blocks have been drafted:
            | Time period name             | Description                             | Organisation              | Updated at |
            | British Summer Time          | The period of daylight savings          | Department of Placeholder | 10/05/2026 |
            | Summer Internship Scheme     | Temporary summer placement scheme       | Ministry of Example       | 10/05/2025 |
            | Winter Fuel Allowance        | Financial support for winter heating    | Department of Placeholder | 10/05/2026 |
            | Summer Leave Policy 2024     | Old leave guidance for staff            | Department of Placeholder | 15/06/2024 |
            | Student loan repayment period| The repayment period for a student loan | Ministry of Example       | 01/02/2026 |

Scenario: GDS Editor can combine filters to find relevant search results
  When I visit the V2 index page
  And I enter the keyword "Summer"
  And I select the lead organisation "Department of Placeholder"
  And I fill in "Last updated from" date with "01", "01", "2026"
  When I click to view results
  Then I should see "British Summer Time"
  And I should not see "Student loan repayment period"

Scenario: GDS Editor sees errors when searching by invalid dates
  When I visit the V2 index page
  And I fill in "Last updated from" date with "41", "01", "2026"
  And I fill in "Last updated to" date with "13", "13", "2026"
  When I click to view results
  Then I should see a message that the filter dates are invalid

Scenario: GDS Editor can view more than one page
  Given 11 time period content blocks exist
  When I visit the V2 index page
  Then I should see 10 content blocks
  And I click on page 2
  Then I should see 1 content block

Scenario: Blocks are ordered by most recently created edition
  Given a content block exists with title "Older document" created 2 days ago
  And a content block exists with title "Newer document" created 1 hour ago
  When I visit the V2 index page
  Then I should see "Newer document" listed before "Older document"