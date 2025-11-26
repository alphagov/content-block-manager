Feature: Delete a content object

  Background:
    Given I am logged in
    And I have the "pre_release_features" permission
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
    Given a pension content block has been drafted

  Scenario: GDS editor creates a Pension and deletes it
    When I am viewing the draft edition
    And I click the link to go to the delete page
    And I click the button to delete
    Then I should see a tag containing "Deleted"
