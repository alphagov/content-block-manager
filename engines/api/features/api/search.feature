Feature: /api/blocks/search
  Scenario: Search for content blocks
    When I access the API endpoint "/api/blocks/search"
    Then the response should have status code 200
