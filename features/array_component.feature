Feature: Use array component

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And a schema "contact" exists:
    """
    {
       "type":"object",
       "additionalProperties":false,
       "properties":{
          "description": {
            "type": "string"
          }
       }
    }
    """
    And the schema has a subschema "teams":
    """
    {
      "type":"object",
      "required": [
        "title"
      ],
      "properties": {
        "title": {
          "type": "string"
        },
        "people": {
          "type": "array",
          "items": {
            "type": "object",
            "required": [
              "name",
              "email"
            ],
            "properties": {
              "name": {
                "type": "string"
              },
              "email": {
                "type": "string"
              }
            }
          }
        }
      }
    }
    """
    And I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "contact" schema
    And I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic company | this is basic | Ministry of Example | this is important  |

    Scenario: Multiple items can be added when Javascript is disabled
      When I click to add a new "team"
      And I fill in the "teams" form with the following fields:
        | title  | people_0_name | people_0_email       |
        | Team 1 | Alice         | alice@example.com  |
      And I click to add another "person"
      And I fill in the "teams" form with the following fields:
        | people_1_name | people_1_email       |
        | Bob           | bob@example.com  |
      And I save and continue
      Then I should see the details for each team's person

  @javascript
  Scenario: Multiple items can be added when Javascript is enabled
    When I click to add a new "team"
    And I fill in the "teams" form with the following fields:
      | title  | people_0_name | people_0_email       |
      | Team 1 | Alice         | alice@example.com  |
    And I click to add another "person"
    And I fill in the "teams" form with the following fields:
      | people_1_name | people_1_email       |
      | Bob           | bob@example.com  |
    And I save and continue
    Then I should see the details for each team's person

  Scenario: Items can be deleted when Javascript is disabled
    When I click to add a new "team"
    And I fill in the "teams" form with the following fields:
      | title  | people_0_name | people_0_email       |
      | Team 1 | Alice         | alice@example.com  |
    And I click to add another "person"
    And I fill in the "teams" form with the following fields:
      | people_1_name | people_1_email       |
      | Bob           | bob@example.com  |
    And I save and continue
    When I click to edit the first team
    And I check the first person's destroy checkbox
    And I save and continue
    Then I should see the details for each team's person
    And I should not see "Alice" on the page
    And I should not see "alice@example.com" on the page

  @javascript
  Scenario: Items can be deleted when Javascript is enabled
    When I click to add a new "team"
    And I fill in the "teams" form with the following fields:
      | title  | people_0_name | people_0_email       |
      | Team 1 | Alice         | alice@example.com  |
    And I click to add another "person"
    And I fill in the "teams" form with the following fields:
      | people_1_name | people_1_email       |
      | Bob           | bob@example.com  |
    And I save and continue
    When I click to edit the first team
    And I click to delete the first person
    And I save and continue
    Then I should see the details for each team's person
    And I should not see "Alice" on the page
    And I should not see "alice@example.com" on the page
