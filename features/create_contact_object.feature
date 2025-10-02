Feature: Create a contact object

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
          },
          "order": {
            "type": "array",
            "items": {
              "type": "string",
              "pattern": "^addresses|contact_links|email_addresses|telephones.[a-z0-9]+(?:-[a-z0-9]+)*$"
            }
          }
       }
    }
    """
    And the schema has a subschema "email_addresses":
    """
    {
      "type":"object",
      "required": ["title", "email_address"],
      "properties": {
        "title": {
          "type": "string"
        },
        "label": {
          "type": "string"
        },
        "email_address": {
          "type": "string"
        },
        "subject": {
          "type": "string"
        },
        "body": {
          "type": "string"
        },
        "description": {
          "type": "string"
        }
      }
    }
    """
    And the schema has a subschema "telephones":
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
        "video_relay_service": {
          "type": "object",
          "properties": {
            "show": {
              "type": "boolean",
              "default": false
            },
            "prefix": {
              "type": "string",
              "default": "**Default** prefix: 18000 then"
            },
            "telephone_number": {
              "type": "string",
              "default": "0800 123 4567"
            }
          }
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
              "default": false
            }
          }
        },
        "bsl_guidance": {
          "type": "object",
          "properties": {
            "show": {
              "type": "boolean",
              "default": false
            },
            "value": {
              "type": "string",
              "default": "British Sign Language (BSL) [video relay service](https://connect.interpreterslive.co.uk/vrs?ilc=DWP)> if you’re on a computer - find out how to [use the service on mobile or tablet](https://www.youtube.com/watch?v=oELNMfAvDxw)"
            }
          }
        },
        "opening_hours": {
          "type": "object",
          "properties": {
            "opening_hours": {
              "type": "string"
            },
            "show_opening_hours": {
              "type": "boolean",
              "default": false
            }
          },
          "if": {
            "properties": {
              "show_opening_hours": {
                "const": true
              }
            }
          },
          "then": {
            "required": [
              "opening_hours"
            ]
          },
          "else": {
            "required": []
          }
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
    And the schema has a subschema "addresses":
    """
    {
      "type":"object",
      "properties": {
        "country": {
          "type": "string"
        },
        "description": {
          "type": "string"
        },
        "postal_code": {
          "type": "string"
        },
        "recipient": {
          "type": "string"
        },
        "state_or_county": {
          "type": "string"
        },
        "street_address": {
          "type": "string"
        },
        "title": {
          "type": "string",
          "default": "Address"
        },
        "town_or_city": {
          "type": "string"
        }
      }
    }
    """

    And the schema "contact" has a group "contact_methods" with the following subschemas:
      | email_addresses | telephones | contact_links |
    And I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "contact" schema
    And I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic contact | this is basic | Ministry of Example | this is important  |

  @javascript
  Scenario: GDS editor can preview a Contact
    When I click on Preview
    Then I should see a preview of my contact
    When I click to close the preview
    And I click on the "email_addresses" subschema
    And I complete the "email_address" form with the following fields:
      | title     | label         | email_address    | subject  | body             |
      | Email us  | Send an email | foo@example.com  | Your ref | Name and address |
    When I click on Preview
    Then I should see a preview of my contact
    When I click to close the preview
    Then I should see the add contact methods screen
    When I save and continue
    And I click on Preview
    When I click to close the preview
    Then I should see the review contact screen

  @javascript
  Scenario: GDS editor can reorder a Contact
    When I click on the "email_addresses" subschema
    And I complete the "email_address" form with the following fields:
      | title     | label         | email_address    | subject  | body             |
      | Email us  | Send an email | foo@example.com  | Your ref | Name and address |
    And I click to add another "contact_method"
    And I click on the "contact_links" subschema
    And I complete the "contact_link" form with the following fields:
      | title              | label      | url                | description |
      | Contact Form       | Contact Us | http://example.com | Description |
    And I click to add another "contact_method"
    And I click on the "addresses" subschema
    And I complete the "addresses" form with the following fields:
      | recipient  | street_address  | town_or_city | postal_code |
      | Recipient  | 123 Fake Street | Springfield  | ABC 123     |
    And I click on Preview
    And I click on reorder
    And I change the order of the contact methods
    Then I should see the contact methods in the new order
    When I click to save the order
    Then I should see a preview of my contact
    And the contact methods should be in the new order
    When I click to close the preview
    And I save and continue
    And I review and confirm my answers are correct
    Then I should be taken to the confirmation page for a new "contact"
    When I click to view the content block
    Then the contact methods should be in the new order

  @javascript
  Scenario: GDS editor creates a Contact with an email address and a telephone
    And I click on the "email_addresses" subschema
    And I complete the "email_address" form with the following fields:
      | title     | label         | email_address    | subject  | body             |
      | Email us  | Send an email | foo@example.com  | Your ref | Name and address |
    And I click to add another "contact_method"
    And I click on the "telephones" subschema
    And I fill in the "telephone" form with the following fields:
      | title            |
      | New phone number |
    And I add the following "telephone_numbers" to the form:
      | label       | telephone_number |
      | Telephone 1 | 12345            |
      | Telephone 2 | 6789             |
    And I indicate that the video relay service info should be displayed
    And I provide custom video relay service info where available
    And I indicate that the call charges info URL should be shown
    And I change the call charges info URL from its default value
    And I change the call charges info label from its default value
    And I indicate that BSL guidance should be shown
    And I change the BSL guidance label from its default value
    And I indicate that the opening hours should be shown
    And I input the opening hours
    And I save and continue
    And I click to add another "contact_method"
    And I click on the "contact_links" subschema
    And I fill in the "contact_link" form with the following fields:
      | title              | label      | url                | description |
      | Contact Form       | Contact Us | http://example.com | Description |
    When I save and continue
    Then I should be on the "add_group_contact_methods" step
    When I save and continue
    And I review and confirm my answers are correct
    Then I should be taken to the confirmation page for a new "contact"
    When I click to view the content block
    And I should see the created embedded object of type "email_address"
    And I should see the created embedded object of type "telephone"
    And I should see the created embedded object of type "contact_link"
    When I view all the telephone attributes
    Then I should see that the call charges fields have been changed
    And I should see that the video relay service info is to be shown
    And I should see that the custom video relay info has been recorded
    And I should see that the BSL guidance fields have been changed

  @javascript
  Scenario: GDS editor sees errors for invalid telephone objects
    And I click on the "telephones" subschema
    When I save and continue
    Then I should see errors for the required nested "telephone_number" fields

  Scenario: GDS editor edits answers during creation of an object
    And I click on the "email_addresses" subschema
    And I complete the "email_address" form with the following fields:
      | title     | email_address          |
      | New email | foo@example.com        |
    And I save and continue
    When I click the first edit link
    And I complete the form with the following fields:
      | title            |
      | New email 2 |
    And I save and continue
    Then I am asked to review my answers
    And I confirm my answers are correct
    And I review and confirm my answers are correct
    And I should be taken to the confirmation page for a new "contact"

  Scenario: Block editor sees expected Govspeak-enabled fields
    When I am creating a contact content block
    Then I see that the block description is Govspeak-enabled
    When I am creating a contact address
    Then I see that the contact address description is Govspeak-enabled
    When I am creating a contact link
    Then I see that the contact link description is Govspeak-enabled
    When I am creating an email address
    Then I see that the contact email address description is Govspeak-enabled
    When I am creating a telephone
    Then I see that the contact telephone description is Govspeak-enabled
    And I see that the telephone video relay service prefix is Govspeak-enabled
    And I see that the telephone bsl guidance value is Govspeak-enabled
    And I see that the telephone opening hours field is Govspeak-enabled





