Feature: Host document preview
  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And a pension content block has been created
    And dependent content exists for a content block
    And the show_snippets feature flag is not turned on

  @javascript
  Scenario: GDS editor can preview a host document
    Given there is a published host document with a link
    When I visit the preview page for the block and the published host document
    Then I should see the state of the host document
    When I click on a link within the frame
    Then I should see the content of the linked page

  @javascript
  Scenario: GDS editor can preview a draft host document
    Given there is a draft host document with a link
    When I visit the preview page for the block and the draft host document
    Then I should see the state of the host document
    When I click on a link within the frame
    Then I should see the content of the linked page

  @javascript
  Scenario: GDS editor can preview a host document within a smart answer
    Given there is a host document that is a smart answer
    When I visit the preview page for the block and the published host document
    And I complete the smart answer form
    Then I should see the content of the linked page
