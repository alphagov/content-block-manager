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

  Scenario: GDS editor creates a Pension and deletes it
    Given a pension content block has been drafted

    When I am viewing the draft edition
    And I click the link to go to the delete page
    And I click the button to delete
    Then I see a notification that the transition to deleted was successful

    When I visit the Content Block Manager home page
    Then I should not see the content block listed

  Scenario: GDS editor creates an edition for an existing block and deletes it
    Given a pension content block has been created
    And a pension content block has been drafted

    When I am viewing the draft edition
    And I click the link to go to the delete page
    And I click the button to delete
    Then I see a notification that the transition to deleted was successful

    When I visit the Content Block Manager home page
    Then I should see the content block listed
    And the content block should have the tag "Published"

