Feature: /api/blocks/search
  Background:
    Given the organisation "Ministry of Example" exists
    And the organisation "Ministry of Silly Walks" exists
    And there are the following published content blocks:
      | title                | organisation            | block_type   |
      | First example block  | Ministry of Example     | pension      |
      | Second example block | Ministry of Example     | contact      |
      | Third example block  | Ministry of Silly Walks | time_period  |

  Scenario: Search for content blocks without arguments
    When I access the search API endpoint without any parameters
    Then the response is a list containing 3 blocks
    And one block has the following attributes:
      | title               |
      | First example block |
    And another block has the following attributes:
      | title                |
      | Second example block |
    And another block has the following attributes:
      | title               |
      | Third example block |

    Scenario: Search by block type
      When query the search API endpoint for block type "pension"
      Then the response is a list containing 1 block
      And one block has the following attributes:
        | title               |
        | First example block |

    Scenario: Search by organisation
      When I query the search API endpoint for the organisation "Ministry of Silly Walks"
      Then the response is a list containing 1 block
      And one block has the following attributes:
        | title               |
        | Third example block |

    Scenario: Search by keyword
      When I query the search API endpoint for the keyword "second"
      Then the response is a list containing 1 block
      And one block has the following attributes:
        | title                |
        | Second example block |

    Scenario: Pagination of search results
      Given the API has been configured to return one result per page
      When I query the search API endpoint for the first page of results
      Then the response is a list containing 1 block
      And one block has the following attributes:
        | title                |
        | First example block |
      And the pagination response has the following attributes:
        | key           | value |
        | total         | 3     |
        | pages         | 3     |
        | current_page  | 1     |
      And the pagination response has the following links:
        | rel                  | href                                            |
        | next                 | http://www.example.com/api/blocks?page=2 |
        | self                 | http://www.example.com/api/blocks?page=1 |
      And I query the search API endpoint for the second page of results
      Then the response is a list containing 1 block
      And one block has the following attributes:
        | title                |
        | Second example block |
      And the pagination response has the following attributes:
        | key           | value |
        | total         | 3     |
        | pages         | 3     |
        | current_page  | 2     |
      And the pagination response has the following links:
        | rel                  | href                                            |
        | next                 | http://www.example.com/api/blocks?page=3 |
        | previous             | http://www.example.com/api/blocks?page=1 |
        | self                 | http://www.example.com/api/blocks?page=2 |
      And I query the search API endpoint for the third page of results
      Then the response is a list containing 1 block
      And one block has the following attributes:
        | title               |
        | Third example block |
      And the pagination response has the following attributes:
        | key           | value |
        | total         | 3     |
        | pages         | 3     |
        | current_page  | 3     |
      And the pagination response has the following links:
        | rel                  | href                                            |
        | previous             | http://www.example.com/api/blocks?page=2 |
        | self                 | http://www.example.com/api/blocks?page=3 |
