Feature: View consolidated host content metrics
  So that I have an overview of how content blocks are used across GOV.UK
  As a stakeholder or team member
  I want to see the rollup metrics for every block in one table

  Background:
    Given I am logged in
    And I have the "view_metrics" permission
    And a pension block "New state pension" has rollup metrics:
      | organisation  | Department for Work and Pensions |
      | locations     | 7                                |
      | instances     | 20                               |
      | views         | 98731                            |
      | organisations | 1                                |
      | refreshed_at  | 2011-11-10 02:00:00              |
    And a contact block "CMA press office" has rollup metrics:
      | organisation  | Competition and Markets Authority |
      | locations     | 129                               |
      | instances     | 129                               |
      | views         | 11234                             |
      | organisations | 1                                 |
      | refreshed_at  | 2011-11-11 09:30:00               |

  Scenario: Can compare how every block is used, at a glance
    When I visit the host content metrics page
    Then I should see the blocks in this order:
      | New state pension |
      | CMA press office  |
    And I should see these metrics for "New state pension":
      | organisation  | Department for Work and Pensions                  |
      | block type    | Pension                                           |
      | embed code    | {{embed:content_block_pension:new-state-pension}} |
      | locations     | 7                                                 |
      | instances     | 20                                                |
      | views         | 98.7k                                             |
      | organisations | 1                                                 |
    And the title "New state pension" should link to the block's page

  Scenario: Blocks not yet measured aren't mistaken for unused ones
    Given a draft pension block "Unpublished pension" has no rollup metrics
    When I visit the host content metrics page
    Then I should see the blocks in this order:
      | New state pension   |
      | CMA press office    |
      | Unpublished pension |
    And I should see "–" for each metric of "Unpublished pension"

  Scenario: Can rank blocks by the measure that matters to me
    When I visit the host content metrics page
    And I sort the metrics by "Organisation"
    Then I should see the blocks in this order:
      | CMA press office  |
      | New state pension |
    When I sort the metrics by "Organisation" again
    Then I should see the blocks in this order:
      | New state pension |
      | CMA press office  |

    When I sort the metrics by "Block type"
    Then I should see the blocks in this order:
      | CMA press office  |
      | New state pension |
    When I sort the metrics by "Block type" again
    Then I should see the blocks in this order:
      | New state pension |
      | CMA press office  |

  Scenario: Can tell how current the figures are
    When I visit the host content metrics page
    Then I should see "Data no older than: 10 November 2011 at 2:00am"

  Scenario: Can find the metrics from anywhere in the app
    When I visit the Content Block Manager home page
    And I click "Metrics" in the header
    Then I should be on the host content metrics page

  Scenario: Looking at a block keeps its figures up to date
    Given dependent content exists for a content block
    When I view that block's page
    And I visit the host content metrics page
    Then I should see that block's rollup data in the metrics table

  Scenario: Users without permission cannot see the metrics
    Given I do not have the "view_metrics" permission
    When I visit the Content Block Manager home page
    Then I should not see "Metrics" in the header
    When I visit the host content metrics page
    Then I should see a permissions error
