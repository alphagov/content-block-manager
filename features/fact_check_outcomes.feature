Feature: Editor records fact check outcome and publishes edition
  Background:
    Given I am logged in
    And I have the "pre_release_features" permission
    And the organisation "Ministry of Example" exists
    And the schema "pension" exists
    And a pension content block is awaiting fact check

  Scenario: Complete fact check, publishing the edition
    Given I am viewing the edition awaiting fact check
    Then I see a principal call to action of 'Publish block'

    When I opt to complete the fact check process
    Then I am required to provide the outcome of the fact check process

    When I provide the outcome of the fact check process
    Then I am required to provide the subject matter expert

    When I provide the subject matter expert
    Then I see a notification that the transition to Published was successful
    And I see that the edition is in published state
    And I should see the pension created event on the timeline
    And the calls to action are suited to the published state

  Scenario: Attempt to publish the edition without supplying fact check outcome
    Given I am viewing the edition awaiting fact check
    Then I see a principal call to action of 'Publish block'

    When I opt to complete the fact check process
    And I attempt to proceed without supplying the outcome of the fact check process
    Then I see that I need to indicate whether the fact check process was performed or skipped

  Scenario: Attempt to make an invalid transition to 'published'
    Given I am viewing the edition awaiting fact check
    And I see a principal call to action of 'Publish block'

    Given the edition has been put into the published state by another process
    And I opt to complete the fact check process
    And I provide the outcome of the fact check process
    And I provide the subject matter expert
    Then I see an alert that the transition failed to transition to published
