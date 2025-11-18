Feature: Search for a content object
  Background:
    Given I am logged in
    And the organisation "Department of Placeholder" exists
    And the organisation "Ministry of Example" exists
    And a schema "pension" exists:
    """
    {
       "type":"object",
       "required":[
          "description"
       ],
       "additionalProperties":false,
       "properties":{
          "description": {
            "type": "string"
          }
       }
    }
    """
    And 1 content blocks of type pension have been created with the fields:
      | title |  a pension |
      | description  | ABC123 |
      | organisation | Department of Placeholder |
      | instructions_to_publishers | for GDS use only |
    And a schema "contact" exists:
    """
    {
       "type":"object",
       "required":[
          "description"
       ],
       "additionalProperties":false,
       "properties":{
          "description": {
            "type": "string"
          }
       }
    }
    """
    And 1 content blocks of type contact have been created with the fields:
      | title | example search title |
      | description  | hello example |
      | organisation | Department of Placeholder |
    And 1 content blocks of type contact have been created with the fields:
      | title | ministry address |
      | description  | ministry example |
      | organisation | Ministry of Example |

  Scenario: GDS Editor can filter by organisation
    When I visit the Content Block Manager home page
    Then 'all organisations' is already selected as a filter
    And "3" content blocks are returned in total
    When I select the lead organisation "Department of Placeholder"
    And I click to view results
    Then "2" content blocks are returned in total
    Then I should see the details for all documents from "Department of Placeholder"

  Scenario: GDS Editor searches for a content object by keyword in instructions to publishers
    When I visit the Content Block Manager home page
    And I enter the keyword "GDS"
    And I click to view results
    Then I should see the content block with title "a pension" returned
    And "1" content block is returned in total

  Scenario: GDS Editor searches for a content object by keyword in title
    When I visit the Content Block Manager home page
    And I enter the keyword "example search"
    And I click to view results
    Then I should see the content block with title "example search title" returned
    And "1" content block is returned in total

  Scenario: GDS Editor searches for a content object by keyword in details
    When I visit the Content Block Manager home page
    And I enter the keyword "ABC123"
    And I click to view results
    Then I should see the content block with title "a pension" returned
    And "1" content block is returned in total

  Scenario: GDS Editor searches for a content object by block type
    When I visit the Content Block Manager home page
    And I select the lead organisation "All organisations"
    And I check the block type "Contact"
    And I click to view results
    And "2" content blocks are returned in total

  Scenario: GDS Editor searches for a content object by lead organisation
    When I visit the Content Block Manager home page
    And I select the lead organisation "Ministry of Example"
    And I click to view results
    And "1" content block is returned in total

  Scenario: GDS Editor searches for a content object by last updated date
    When one of the content blocks was updated 2 days ago
    When I visit the Content Block Manager home page
    And I add a filter for blocks updated two days ago
    And I click to view results
    And "1" content block is returned in total

  Scenario: Editor searches for object by embed code
    When I visit the Content Block Manager home page
    And I search using the embed code for the pension block
    Then the pension block is found
    And "1" content block is returned in total

    When I search using the content_id_alias part of the embed code for the contact block
    Then the contact block is found
    And "1" content block is returned in total

    When I search using the embed code for the pension block with an attribute reference
    Then the pension block is found
    And "1" content block is returned in total

  Scenario: GDS Editor sees errors when searching by invalid dates
    When I visit the Content Block Manager home page
    And I input invalid dates to filter by
    And I click to view results
    Then I should see a message that the filter dates are invalid

  Scenario: GDS Editor can view more than one page
    When 1 content blocks of type pension have been created with the fields:
      | title |  page 2 edition |
      | description  | ABC123 |
      | organisation | Department of Placeholder |
      | instructions_to_publishers | for GDS use only |
    And 15 content blocks of type contact have been created with the fields:
      | title | page 1 edition |
      | description  | ABC123 |
      | organisation | Ministry of Example |
    When I visit the Content Block Manager home page
    And I enter the keyword "ABC123"
    And I click to view results
    Then I should see the content block with title "page 1 edition" returned
    And I click on page 2
    Then I should see the content block with title "page 2 edition" returned

  Scenario: Blocks are ordered by most recently updated
    When the block "example search title" has been updated
    And I visit the Content Block Manager home page
    Then the block "example search title" should appear as the first item in the list

  Scenario: E2E documents are not shown
    When the block "example search title" has testing_artefact set to true
    And I visit the Content Block Manager home page
    Then I should not see the content block with title "example search title" returned

  Scenario: E2E documents are shown to E2E users
    Given I am logged in as an E2E user
    When the block "example search title" has testing_artefact set to true
    And I visit the Content Block Manager home page
    Then I should see the content block with title "example search title" returned
