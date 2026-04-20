Feature: User is warned about creating a block with a non-unique title
  - As an editor creating a content block
  - So that I don't accidentally create a block with the same title as an existing block
  - I want to be prompted before I create a block with a non-unique title

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And 1 content blocks of type pension have been created with the fields:
      | title                       | my title            |
      | description                 | ABC123              |
      | organisation                | Ministry of Example |
      | instructions_to_publishers  | for GDS use only    |

  Scenario Outline: Creating a block with a non-unique title
    When I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "<schema>" schema
    And I complete the form with the following fields:
      | title     | description      | organisation        |
      | my title  | Some description | Ministry of Example |
    Then I should see an error message indicating that the title is not unique
    When I save and continue
    Then the duplicate title validation check will have been skipped

  Examples:
    | schema      |
    | pension     |
    | contact     |
    | time_period |
    | tax         |
