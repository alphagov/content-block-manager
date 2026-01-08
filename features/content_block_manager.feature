Feature: Content block manager

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists

  @javascript
  Scenario: Correct layout is used
    When I visit the Content Block Manager home page
    Then I should see the object store's home page title
    Then I should see the object store's title in the header
    And I should see the object store's navigation
    And I should see the object store's phase banner
    And there should be no accessibility errors

  Scenario: See warning when pre-release features are enabled
    Given I have the "pre_release_features" permission
    When I visit the Content Block Manager home page
    Then I see the warning that the pre-release features are enabled

  Scenario: Don't warning when pre-release features are not enabled
    Given I do not have the "pre_release_features" permission
    When I visit the Content Block Manager home page
    Then I do not see the warning that the pre-release features are enabled
