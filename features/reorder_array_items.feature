@javascript
Feature: Editor is able to reorder their telephone number fields
  - As an editor who has spent time inputting telephone number fields
  - So that I don't have to delete items or start again
  - I want to be able to reorder my fields into the order I want

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "contact" schema
    And I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic contact | this is basic | Ministry of Example | this is important  |

  Scenario: Creating an edition and changing the order of the telephone numbers
    When I click on the "telephones" subschema
    And I fill in the "telephone" form with the following fields:
      | title              |
      | Many phone numbers |
    And I add the following "telephone_numbers" to the form:
      | label       | telephone_number |
      | Telephone 1 |                1 |
      | Telephone 2 |                2 |
      | Telephone 3 |                3 |
      | Telephone 4 |                4 |
    And I reorder the 2nd item up
    And I reorder the 3rd item down
    And I save and continue
    Then I should see the items are in the order:
      | label       | telephone_number |
      | Telephone 2 |                2 |
      | Telephone 1 |                1 |
      | Telephone 4 |                4 |
      | Telephone 3 |                3 |
    And I save and open the page
