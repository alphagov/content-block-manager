Feature: Edit contact's embedded objects

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

  Scenario: Nested objects show default values when editing
    Given the schema has a subschema "telephones":
    """
    {
      "type":"object",
      "required": [
        "title",
        "telephone_numbers"
      ],
      "properties": {
        "telephone_numbers": {
          "type": "array",
          "items": {
            "type": "object",
            "required": [
              "label",
              "telephone_number"
            ],
            "properties": {
              "label": {
                "type": "string"
              },
              "telephone_number": {
                "type": "string"
              }
            }
          }
        },
        "title": {
          "type": "string"
        },
        "description": {
          "type": "string"
        },
        "call_charges": {
          "type": "object",
          "properties": {
            "label": {
              "type": "string",
              "default": "Find out about call charges"
            },
            "call_charges_info_url": {
              "type": "string",
              "default": "https://gov.uk/call-charges"
            },
            "show_call_charges_info_url": {
              "type": "boolean",
              "default": true
            }
          }
        }
      }
    }
    """
    And the schema "contact" has a group "contact_methods" with the following subschemas:
      | contact_links     |
      | telephone_numbers |
    And a published contact edition exists
    When I visit the Content Block Manager home page
    And I click to view the document
    And I click to edit the "contact"
    And I save and continue
    When I click to add another "contact method"
    And I click on the "telephones" subschema
    Then the "edition_details_telephones_call_charges_show_call_charges_info_url" field should be checked
    And the "edition_details_telephones_call_charges_call_charges_info_url" field should be set to "https://gov.uk/call-charges"
    And the "edition_details_telephones_call_charges_label" field should be set to "Find out about call charges"

