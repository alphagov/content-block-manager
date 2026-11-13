Feature: Disable block creation
  - So that we halt the creation of blocks while we consider the future of Content Block Manager
  - As a regular user of Content Block Manager
  - I want to be prevented from making new blocks

  Background:
    Given the organisation "Ministry of Example" exists
    And I am logged in

  Scenario: When disable_block_creation flag is ENABLED, user WITHOUT 'create_blocks'can NOT create blocks
    Given the disable_block_creation flag is enabled
    And I do not have the "create_blocks" permission
    
    When I visit the Content Block Manager home page
    Then I should not have the ability to create blocks
    And I should see a notice explaining why block creation is disabled

  Scenario: When disable_block_creation flag is ENABLED, user WITH 'create_blocks' permission CAN create blocks
    Given the disable_block_creation flag is enabled
    And I have the "create_blocks" permission
    
    When I visit the Content Block Manager home page
    Then I should have the ability to create blocks
    And I should not see a notice explaining that block creation is disabled

  Scenario: When disable_block_creation flag is DISABLED, user WITHOUT 'create_blocks'can create blocks
    Given the disable_block_creation flag is disabled
    And I do not have the "create_blocks" permission
    
    When I visit the Content Block Manager home page
    Then I should have the ability to create blocks
    And I should not see a notice explaining that block creation is disabled

  Scenario: When disable_block_creation flag is DISABLED, user WITH 'create_blocks' permission CAN create blocks
    Given the disable_block_creation flag is disabled
    And I have the "create_blocks" permission
    
    When I visit the Content Block Manager home page
    Then I should have the ability to create blocks
    And I should not see a notice explaining that block creation is disabled
