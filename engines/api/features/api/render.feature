Feature: /api/blocks/render
  Background:
    Given the organisation "Ministry of Example" exists
    And there are the following published content blocks:
      | title               | organisation        | block_type |
      | State Pension block | Ministry of Example | pension    |
      | Tax year block      | Ministry of Example | pension    |

  Scenario: Render html for known embed codes
    When I query the render API endpoint for the following content blocks:
      | title               |
      | State Pension block |
      | Tax year block      |
    Then the response contains 2 rendered blocks
    And the rendered block for "State Pension block" includes title "State Pension block"
    And the rendered block for "Tax year block" includes title "Tax year block"

  Scenario: Ignore unknown embed codes
    When I query the render API endpoint with the following embed codes:
      | embed_code                |
      | {{embed:unknown}}         |
    Then the response contains 0 rendered blocks

  Scenario: Render works with embed code features
    When I query the render API endpoint for "State Pension block" with the following features or paths:
      | feature    |
      | #section-a |
    Then the response contains 1 rendered blocks
    And the rendered block for "State Pension block" includes title "State Pension block"

  Scenario: Render html for Time period content blocks
    Given there are the following published content blocks:
      | title            | organisation        | block_type  | details                                                                          |
      | Test time period | Ministry of Example | time_period | {"date_range": {"start": "2026-11-05T00:00:00Z", "end": "2028-02-22T23:59:59Z"}} |
    When I query the render API endpoint for "Test time period" with the following features or paths:
      | feature                |
      |                        |
      | #start_day_and_month   |
      | /date_range/start      |
    Then the response contains 3 rendered blocks
    And the rendered block for "Test time period" includes:
      | title            | block_type  |
      | Test time period | Time period |
    And the rendered block for "Test time period" includes html:
      """
      5 November 2026 to 22 February 2028
      """
    And the rendered block for "Test time period#start_day_and_month" includes:
      | title            | block_type  |
      | Test time period | Time period |
    And the rendered block for "Test time period#start_day_and_month" includes html:
      """
      5 November
      """
    And the rendered block for "Test time period/date_range/start" includes:
      | title            | block_type  |
      | Test time period | Time period |
    And the rendered block for "Test time period/date_range/start" includes html:
      """
      5 November 2026
      """