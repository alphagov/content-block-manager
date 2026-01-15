Feature: Editor records Factcheck outcome and publishes edition
  Background:
    Given I am logged in
    And I have the "pre_release_features" permission
    And the organisation "Ministry of Example" exists
    And the schema "pension" exists
    And a pension content block is awaiting factcheck

  Scenario: Complete factcheck, publishing the edition
    Given I am viewing the edition awaiting factcheck
    Then I see a principal call to action of 'Publish block'

    When I opt to complete the factcheck process
    Then I am required to provide the outcome of the factcheck process

    When I provide the outcome of the factcheck process
    Then I am required to provide the subject matter expert

    When I provide the subject matter expert
    Then I see a notification that the transition to Published was successful
    And I see that the edition is in published state
    And I should see the pension created event on the timeline
    And the calls to action are suited to the published state

  Scenario: Attempt to publish the edition without supplying factcheck outcome
    Given I am viewing the edition awaiting factcheck
    Then I see a principal call to action of 'Publish block'

    When I opt to complete the factcheck process
    And I attempt to proceed without supplying the outcome of the factcheck process
    Then I see that I need to indicate whether the factcheck process was performed or skipped

  Scenario: Attempt to make an invalid transition to 'published'
    Given I am viewing the edition awaiting factcheck
    And I see a principal call to action of 'Publish block'

    Given the edition has been put into the published state by another process
    And I opt to complete the factcheck process
    And I provide the outcome of the factcheck process
    And I provide the subject matter expert
    Then I see an alert that the transition failed to transition to published
