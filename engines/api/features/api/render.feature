Feature: /api/blocks/:embed_code/render
  Background:
    Given the organisation "Ministry of Example" exists
    And there are the following published content blocks:
      | title               | organisation        | block_type  |
      | First example block | Ministry of Example | pension     |
      | Time period block   | Ministry of Example | time_period |

  Scenario: Render a published content block
    When I query the render API endpoint for the block titled "First example block"
    Then the response is rendered HTML

  Scenario: Render returns not found for an unknown embed code
    When I query the render API endpoint with the embed code "{{embed:content_block_pension:missing-block}}"
    Then the response is a not found error for embed code "{{embed:content_block_pension:missing-block}}"

  Scenario: Render the default block when given an embed code without internal content path or format
    When I query the render API endpoint with the embed code for the block titled "Time period block"
    Then the response is rendered HTML
    And the response contains rendered content for "embed:content_block_time_period:"

  Scenario: Render the internal value when given an embed code which includes an internal content path
    When I query the render API endpoint with the embed code for the block titled "Time period block" and internal content path "date_range/start"
    Then the response is rendered HTML
    And the response contains rendered content for "embed:content_block_time_period:"
    And the response contains rendered content for "date_range/start"

  Scenario: Render the specified format when given an embed code with a format
    When I query the render API endpoint with the embed code for the block titled "Time period block" and format "start_day_and_month"
    Then the response is rendered HTML
    And the response contains rendered content for "embed:content_block_time_period:"
    And the response contains rendered content for "start_day_and_month"
