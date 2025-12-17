Feature: Edit contact's embedded objects

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
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
    And the schema has a subschema "contact_links":
    """
    {
      "type":"object",
      "required": ["url"],
      "properties": {
        "title": {
          "type": "string"
        },
        "label": {
          "type": "string"
        },
        "url": {
          "type": "string"
        },
        "description": {
          "type": "string"
        }
      }
    }
    """

    And the schema "contact" has a group "contact_methods" with the following subschemas:
      | contact_links |
    And a draft contact edition exists

  Scenario: Can cancel creation of new contact method
    Given I am viewing the draft edition
    And I am viewing the grouped contact methods
    And I choose to add a contact link
    And I then decide to abandon the creation of a new contact link
    Then I should be returned to the view of grouped contact methods
