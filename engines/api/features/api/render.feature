Feature: /api/blocks/:embed_code/render
  Background:
    Given the organisation "Ministry of Example" exists
    And there are the following published content blocks:
      | title               | organisation        | block_type |
      | First example block | Ministry of Example | pension    |

  Scenario: Render a published content block
    When I query the render API endpoint for the block titled "First example block"
    Then the response is rendered HTML
    And the response contains rendered content for "First example block"

  Scenario: Render returns not found for an unknown embed code
    When I query the render API endpoint with the embed code "{{embed:content_block_pension:missing-block}}"
    Then the response is a not found error for embed code "{{embed:content_block_pension:missing-block}}"

