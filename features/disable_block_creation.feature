Feature: Disable block creation
  - So that we halt the creation of blocks while we consider the future of Content Block Manager
  - As a regular user of Content Block Manager
  - I want to be prevented from making new blocks

  Background:
    Given the organisation "Ministry of Example" exists
    And I am logged in

  Scenario: When disable_block_creation flag is ENABLED
    Given the disable_block_creation flag is enabled
    When I visit the Content Block Manager home page
    Then I should not have the ability to create blocks
    And I should see a notice explaining why block creation is disabled

  Scenario: When disable_block_creation flag is DISABLED
    Given the disable_block_creation flag is disabled
    When I visit the Content Block Manager home page
    Then I should have the ability to create blocks
    And I should not see a notice explaining that block creation is disabled
