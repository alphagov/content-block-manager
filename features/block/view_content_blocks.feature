Feature: Search for a content object
  Background:
    Given I am logged in
    And the organisation "Department of Placeholder" exists
    And the organisation "Ministry of Example" exists
    And the following time period content blocks have been drafted:
        | Time period name              | Description                             | Organisation              |
        | British Summer Time           | The period of daylight savings          | Department of Placeholder |
        | Student loan repayment period | The repayment period for a student loan | Ministry of Example       |

Scenario: view all available content blocks
    When I visit the blocks index page
    Then I should see the details for all three available content blocks
