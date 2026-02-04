Feature: Create a contact object

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And the schema "contact" exists
    And I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "contact" schema
    And I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic contact | this is basic | Ministry of Example | this is important  |

  @javascript
  Scenario: GDS editor can preview a Contact
    When I click on Preview and reorder
    Then I should see a preview of my contact
    And there should be no accessibility errors
    When I click to close the preview
    And I click on the "email_addresses" subschema
    And I complete the "email_address" form with the following fields:
      | title     | email_address    | subject  | body             |
      | Email us  | foo@example.com  | Your ref | Name and address |
    When I click on Preview and reorder
    Then I should see a preview of my contact
    When I click to close the preview
    Then I should see the add contact methods screen
    When I save and continue
    When I click on Preview and reorder
    When I click to close the preview
    Then I should see the review contact screen

  @javascript
  Scenario: GDS editor can reorder a Contact
    When I click on the "email_addresses" subschema
    And I complete the "email_address" form with the following fields:
      | title           | email_address    | subject  | body             |
      | Email The Team  | foo@example.com  | Your ref | Name and address |
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
    And I click on Preview and reorder
    And I click on reorder
    Then there should be no accessibility errors
    When I change the order of the contact methods
    Then I should see the contact methods in the new order
    When I click to save the order
    Then I should see a preview of my contact
    And the contact methods should be in the new order
    When I click to close the preview
    And I click to add another "contact_method"
    And I click on the "contact_links" subschema
    Then I see see that URL must be supplied in full, with scheme
    When I complete the "contact_link" form with the following fields:
      | title              | label      | url                | description |
      | Other Contact Form | Contact Us | http://example.com | Description |
    And I click on Preview and reorder
    When I click on reorder
    Then I should see "Other Contact Form" in the ordered items
    When I click the cancel link
    And I click to close the preview
    And I save and continue
    And I review and confirm I have checked the content
    Then I should be taken to the confirmation page for a new "contact"
    When I click to view the content block
    Then the contact methods should be in the new order

  @javascript
  Scenario: Editor can reorder a Contact when all contact methods are of one type
    When I click on the "email_addresses" subschema
    And I complete the "email_address" form with the following fields:
      | title           | email_address    |
      | Email The Team  | foo@example.com  |
    And I click to add another "contact_method"
    And I click on the "email_addresses" subschema
    And I complete the "email_address" form with the following fields:
      | title           | email_address        |
      | Email Support   | support@example.com  |
    And I click on Preview and reorder
    When I click on reorder
    Then I should be on the reordering form

  Scenario: Editor is not offered 'reorder' when only one contact method exists
    When I click on the "email_addresses" subschema
    And I complete the "email_address" form with the following fields:
      | title           | email_address    |
      | Email The Team  | foo@example.com  |
    Then I should be offered the preview facility without mention of reordering

  @javascript
  Scenario: GDS editor creates a Contact with an email address and a telephone
    And I click on the "email_addresses" subschema
    Then there should be no accessibility errors
    When I complete the "email_address" form with the following fields:
      | title     | email_address    | subject  | body             |
      | Email us  | foo@example.com  | Your ref | Name and address |
    And I click to add another "contact_method"
    When I click on the "telephones" subschema
    Then there should be no accessibility errors
    When I fill in the "telephone" form with the following fields:
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
    And there should be no accessibility errors
    When I save and continue
    Then there should be no accessibility errors
    When I review and confirm I have checked the content
    Then I should be taken to the confirmation page for a new "contact"
    And the block should have been sent to the Publishing API
    When I click to view the content block
    Then there should be no accessibility errors
    And I should see the created embedded object of type "email_address"
    And I should see the created embedded object of type "telephone"
    And I should see the created embedded object of type "contact_link"
    When I view all the telephone attributes
    Then I should see that the call charges fields have been changed
    And I should see that the video relay service info has been changed
    And I should see that the BSL guidance fields have been changed
    And I should see that the opening hours have been changed
    And analytics messages should have been sent for each step in the workflow
    And analytics messages should have been sent for each embedded object
    When I return to the homepage
    Then I should see the content block with title "my basic contact" returned
    And I should see a tag containing "Published"

  @javascript
  Scenario: GDS editor sees errors for invalid telephone objects
    And I click on the "telephones" subschema
    When I save and continue
    Then I should see errors for the required nested "telephone_number" fields

  Scenario: GDS editor sees errors when not selecting a contact method
    When I save and continue
    Then I should see an error prompting me to choose a contact method

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
    And I confirm I have checked the content
    And I review and confirm I have checked the content
    And I should be taken to the confirmation page for a new "contact"

  Scenario: Fields with default values are not repopulated when editing
    When I click on the "email_addresses" subschema
    And I complete the "email_address" form with the following fields:
      | title     | email_address          |
      |           | foo@example.com        |
    When I click the first edit link
    Then the "title" field should not be populated

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
    And I see that the telephone video relay service source is Govspeak-enabled
    And I see that the telephone bsl guidance value is Govspeak-enabled
    And I see that the telephone opening hours field is Govspeak-enabled





