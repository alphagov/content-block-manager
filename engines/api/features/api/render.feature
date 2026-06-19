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

  Scenario: Render the default block when given an embed code without internal content path or format and check that the embed code but not the format or internal path appear in the data element
    When I query the render API endpoint with the embed code for the block titled "Time period block"
    Then the response is rendered HTML
    And the response contains "embed:content_block_time_period:"
    And the response does not contain "date_range/start"
    And the response does not contain "start_day_and_month"

  Scenario: Render the specified format when given an embed code with an internal path and check that the embed code and internal path appear in the data element
    When I query the render API endpoint with the embed code for the block titled "Time period block" and internal content path "date_range/start"
    Then the response is rendered HTML
    And the response contains "embed:content_block_time_period:"
    And the response contains "date_range/start"
    And the response does not contain "start_day_and_month"

  Scenario: Render the specified format when given an embed code with a format and check that the embed code and format appears in the data element
    When I query the render API endpoint with the embed code for the block titled "Time period block" and format "start_day_and_month"
    Then the response is rendered HTML
    And the response contains "embed:content_block_time_period:"
    And the response contains "start_day_and_month"
    And the response does not contain "date_range/start"
