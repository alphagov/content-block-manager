Feature: Fact check preview
  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And the schema "contact" exists
    And the schema "pension" exists

  Scenario: User can see a preview of a contact block in Fact Check
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
    And I should see the list of host editions referencing my block

  Scenario: User can see a preview of a brand new contact block in Fact Check
    Given a draft contact edition exists
    And that contact has an email address with the following fields:
      | title    | email_address   |
      | my email | bar@example.com |
    When I visit the fact check path for the block
    Then I should see the block's title
    And I should not see a diff
    And I should see "bar@example.com"
    And I should see the list of host editions referencing my block

  Scenario: User can see a preview of a pension block in Fact Check
    Given a pension content block has been created
    And that pension has a rate with the following fields:
      | title      | amount | frequency |
      | my pension | £123   | a day |
    And a pension content block has been drafted
    And that pension has a rate with the following fields:
      | title          | amount | frequency |
      | my pension  | £444   | a month   |
    When I visit the fact check path for the block
    Then I should see the block's title
    And I should see "£123" as a previous value
    And I should see "£444" as a new value
    And I should see "a day" as a previous value
    And I should see "a month" as a new value
    And I should see the list of host editions referencing my block
