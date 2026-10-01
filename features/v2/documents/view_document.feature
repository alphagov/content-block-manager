Feature: View documents
  Background:
    Given I am logged in

Scenario: GDS Editor can see the Show Document page for a Published document
  When I visit a "Published" "Time Period" document
  Then I should see "Time Period 1"
  And I should see the block type is "Time period"
  And I should see that the document state is "Published"
  And I should see "Edit time period"

Scenario: GDS Editor can see the Show Document page for a Draft document
  # To-do:
    # Without state properly implemented, the "Go to published edition" never appears.
    # This test will need splitting into two/updating when that is done
  When I visit a "Draft" "Time Period" document
  Then I should see "Time Period 2"
  And I should see the block type is "Time period"
  And I should see that the document state is "Draft"
  And I should see "Complete draft"
  And I should see "Go to published edition"

  Scenario: GDS Editor can see the Show Document page for a Scheduled document
  # To-do:
    # Without state properly implemented, the "Go to published edition" never appears.
    # This test will need splitting into two/updating when that is done
    When I visit a "Scheduled" "Time Period" document
    Then I should see "Time Period 3"
    And I should see the block type is "Time period"
    And I should see that the document state is "Scheduled"
    And I should see "Edit draft"
    And I should see "Go to published edition"

