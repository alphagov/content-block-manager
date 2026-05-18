Feature: /api/blocks/search
  Background:
    Given the organisation "Ministry of Example" exists
    And there are the following published content blocks:
      | title             | organisation        | block_type   |
      | Example block 1   | Ministry of Example | pension      |
      | Example block 2   | Ministry of Example | contact      |
      | Example block 3   | Ministry of Example | time_period  |

  Scenario: Search for content blocks without arguments
    When I access the search API endpoint without any parameters
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

    Scenario: Search by block type
      When query the search API endpoint for block type "pension"
      Then the response is a list containing 1 block
      And one block has the following attributes:
        | title           |
        | Example block 1 |
