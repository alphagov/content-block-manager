Feature: Fact check preview
  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And the schema "contact" exists

  Scenario: User can see a preview of a block in Fact Check
    Given a published contact edition exists
    And that contact has an email address with the following fields:
      | title    | email_address   |
      | my email | foo@example.com |
    And a draft contact edition exists
    And that contact has an email address with the following fields:
      | title    | email_address   |
      | my email | bar@example.com |
    When I visit the fact check path for the block
    Then I should see the block's title
    And I should see "foo@example.com" as a previous value
    And I should see "bar@example.com" as a new value

  Scenario: User can see a preview of a brand new block in Fact Check
    Given a draft contact edition exists
    And that contact has an email address with the following fields:
      | title    | email_address   |
      | my email | bar@example.com |
    When I visit the fact check path for the block
    Then I should see the block's title
    And I should not see a diff
    And I should see "bar@example.com"
