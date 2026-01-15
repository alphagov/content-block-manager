Feature: View published contact from draft
  - So that I can refer to the published edition of a block
  - As an editor who is looking at newer draft edition
  - I want to view the latest published edition of a block

  Background:
    Given I am logged in
    And I have the "pre_release_features" permission
    And the organisation "Ministry of Example" exists
    And the schema "contact" exists

  Scenario: Editor can follow link to published edition
    Given a published contact edition exists
    And a draft contact edition exists
    And I am viewing the draft edition
    And I should see the content for the draft contact edition

    And I should be able to view the published contact edition
    And I should see the content for the published contact edition
