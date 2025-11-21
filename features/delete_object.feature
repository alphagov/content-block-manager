Feature: Delete a content object

  Background:
    Given I am logged in
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
    And the schema has a subschema "rates":
    """
    {
      "type":"object",
      "required": ["title", "amount"],
      "properties": {
        "title": {
          "type": "string"
        },
        "amount": {
          "type": "string",
          "pattern": "£[0-9]+\\.[0-9]+"
        },
        "frequency": {
          "type": "string",
          "enum": [
            "a week",
            "a month"
          ]
          },
          "description": {
            "type": "string"
          }
      }
    }
    """

  Scenario: GDS editor creates a Pension and deletes it
    When I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "pension" schema
    And I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic pension | this is basic | Ministry of Example | this is important  |
    And I save and continue
    And I review and confirm my answers are correct
    # And I delete the edition
    And I return to the homepage
    Then I should see a tag containing "deleted"
