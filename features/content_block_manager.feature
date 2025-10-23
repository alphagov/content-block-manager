Feature: Content block manager

  @javascript
  Scenario: Correct layout is used
    Given I am logged in
    And the organisation "Ministry of Example" exists
    When I visit the Content Block Manager home page
    Then I should see the object store's home page title
    Then I should see the object store's title in the header
    And I should see the object store's navigation
    And I should see the object store's phase banner
    And there should be no accessibility errors
