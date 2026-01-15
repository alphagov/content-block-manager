Feature: Edit a contact

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And the schema "contact" exists
    And a draft contact edition exists

  Scenario: Can cancel creation of new contact method
    Given I am viewing the draft edition
    And I am viewing the grouped contact methods
    And I click to add another "contact_method"
    And I click on the "contact_link" subschema
    And I then decide to abandon the creation of a new contact link
    Then I should be returned to the view of grouped contact methods

  Scenario: Nested objects show default values when editing
    Given a published contact edition exists
    When I visit the Content Block Manager home page
    And I click to view the document
    And I click to edit the "contact"
    And I save and continue
    When I click to add another "contact method"
    And I click on the "telephones" subschema
    Then the "edition_details_telephones_call_charges_show_call_charges_info_url" field should be checked
    And the "edition_details_telephones_call_charges_call_charges_info_url" field should be set to "https://gov.uk/call-charges"
    And the "edition_details_telephones_call_charges_label" field should be set to "Find out about call charges"

