Feature: View documents
  Background:
    Given I am logged in
    And the organisation "Department of Placeholder" exists
    And the organisation "Ministry of Example" exists
    And the following time period content blocks have been drafted:
      | Time period name             | Description                             | Organisation              | Updated at |
      | British Summer Time          | The period of daylight savings          | Department of Placeholder | 10/05/2026 |
      | Summer Internship Scheme     | Temporary summer placement scheme       | Ministry of Example       | 10/05/2025 |

Scenario: GDS Editor can navigate from the Documents Index page to the Show page for given documents
  Given I visit the V2 index page
  And I click the View link for "British Summer Time"
  Then I am taken to the Show page for "British Summer Time"

  When I click the back link
  Then I am returned to the V2 index page

  And I click the View link for "Summer Internship Scheme"
  Then I am taken to the Show page for "Summer Internship Scheme"

Scenario: GDS Editor can see the Show Document page for a Published document
  Given a "Time period" document in the "Published" state exists
  When I visit that document
  Then I see the document metadata for the "Published" "Time period" document
  And I have the ability to create a new draft edition for the document [not currently functional]

Scenario: GDS Editor can see the Show Document page for a Draft document
  # To-do:
    # Without state properly implemented, the "Go to published edition" never appears.
    # This test will need splitting into two/updating when that is done
  Given a "Time period" document in the "Draft" state exists
  When I visit that document
  Then I see the document metadata for the "Draft" "Time period" document
  And I have the ability to edit the draft edition
  And I have the ability to view the current published edition [not currently functional]

  Scenario: GDS Editor can see the Show Document page for a Scheduled document
  # To-do:
    # Without state properly implemented, the "Go to published edition" never appears.
    # This test will need splitting into two/updating when that is done
    Given a "Time period" document in the "Scheduled" state exists
    When I visit that document
    Then I see the document metadata for the "Scheduled" "Time period" document
    And I have the ability to edit the draft edition
    And I have the ability to view the current published edition [not currently functional]
