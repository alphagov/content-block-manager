@freeze_time
Feature: Editor can use a factcheck link to allow non-signon users to access a block's preview
  Background:
    Given I am logged in
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
    And a pension content block is awaiting factcheck

  @javascript
  Scenario: Editor can see and copy a factcheck link
    When I visit the Content Block Manager home page
    And I click to view the document
    And I click to share the factcheck link
    Then I should see a link to share the block for factcheck
    When I click to copy the link
    Then the link should be copied to my clipboard

  @javascript
  Scenario: Editor can regenerate a factcheck link
    When I visit the Content Block Manager home page
    And I click to view the document
    And I click to share the factcheck link
    Then I should see a link to share the block for factcheck
    When I click to reset the preview link
    Then a new preview link should be generated
