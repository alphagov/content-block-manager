Feature: View documents
  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And the following time period content blocks have been drafted:
      | Time period name             | Description                             | Organisation              | Updated at |
      | British Summer Time          | The period of daylight savings          | Ministry of Example       | 10/05/2026 |
      | Summer Internship Scheme     | Temporary summer placement scheme       | Ministry of Example       | 10/05/2025 |

Scenario: GDS Editor can see the Show Document page
  # TODO: update this once complete to access via the Documents page
  When I visit the document with ID 1
  Then I should see "British Summer Time"
  And I should see "Time period"
