Feature: Hiding alpha block types behind permissions and a feature flag
  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And the schema "pension" exists
    And the schema "pension" is a live schema
    And the schema "tax" exists
    And the schema "tax" is an alpha schema
    And a pension content block has been created
    And a tax content block has been created

  Scenario: Only live block types show when feature flag is not turned on
    Given the show_all_content_block_types feature flag is not turned on
    When I visit the Content Block Manager home page
    Then I should see the pension blocks listed
    And I should not see the tax blocks listed
    And I should be able to filter for pension blocks
    And I should not be able to filter for tax blocks
    When I click to create an object
    Then I should be able to create a pension block
    And I should not be able to create a tax block

  Scenario: All block types show when feature flag is turned on
    Given the show_all_content_block_types feature flag is turned on
    When I visit the Content Block Manager home page
    Then I should see the pension blocks listed
    And I should see the tax blocks listed
    And I should be able to filter for tax blocks
    And I should be able to filter for tax blocks
    When I click to create an object
    Then I should be able to create a pension block
    And I should be able to create a tax block

  Scenario: All block types show when the user has
    Given the show_all_content_block_types feature flag is not turned on
    And I have the "show_all_content_block_types" permission
    When I visit the Content Block Manager home page
    Then I should see the pension blocks listed
    And I should see the tax blocks listed
    And I should be able to filter for tax blocks
    And I should be able to filter for tax blocks
    When I click to create an object
    Then I should be able to create a pension block
    And I should be able to create a tax block
