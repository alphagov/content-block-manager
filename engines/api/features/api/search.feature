Feature: /api/blocks/search
  Background:
    Given the organisation "Ministry of Example" exists

  Scenario: Search for content blocks without arguments
    When there are the following published content blocks:
      | title             | organisation        |
      | Example block 1   | Ministry of Example |
      | Example block 2   | Ministry of Example |
      | Example block 3   | Ministry of Example |
    And I access the API endpoint "/api/blocks/search"
    Then the response is a list containing 3 blocks
    And one block has the following attributes:
      | title           |
      | Example block 1 |
    And another block has the following attributes:
      | title           |
      | Example block 2 |
    And another block has the following attributes:
      | title           |
      | Example block 3 |
