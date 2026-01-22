Feature: Host document preview
  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And the schema "pension" exists
    And a pension content block has been created
    And dependent content exists for a content block

  @javascript
  Scenario: GDS editor can preview a host document
    Given there is a host document with a link
    When I visit the preview page for the block and the host document
    When I click on a link within the frame
    Then I should see the content of the linked page

  @javascript
  Scenario: GDS editor can preview a host document within a smart answer
    Given there is a host document that is a smart answer
    When I visit the preview page for the block and the host document
    And I complete the smart answer form
    Then I should see the content of the linked page
