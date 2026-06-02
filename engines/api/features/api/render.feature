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

  Scenario: Render works with embed code variants
    When I query the render API endpoint for the following content blocks with variants:
      | title               | variant    |
      | State Pension block | #section-a |
    Then the response contains 1 rendered blocks
    And the rendered block for "State Pension block" includes title "State Pension block"