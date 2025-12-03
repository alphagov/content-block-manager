Feature: Editor sends edition to factcheck, recording Review outcome
  - So that I can get feedback from a factchecker before publishing
  - As an editor who has a edition of a block in the 'awaiting review' state
  - I want to record the outcome of the Review process and put my edition into the
    'awaiting_factcheck' state

  Background:
    Given I am logged in
    And I have the "pre_release_features" permission
    And the organisation "Ministry of Example" exists
    And a schema "pension" exists:
    """
    {
       "type":"object",
       "required":[
          "description"
       ],
       "additionalProperties":false,
       "properties":{
          "description": {
            "type": "string"
          }
       }
    }
    """
    And a pension content block in the awaiting_review state exists

  Scenario: Send to factcheck, supplying Review outcome
    Given I am viewing the edition awaiting review
    Then I see a principal call to action of 'Send to factcheck'

    When I opt to send the edition to factcheck
    Then I am required to provide the outcome of the review process

    When I provide the outcome of the review process
    Then I see a notification that the transition to Awaiting factcheck was successful

    And I see that the edition is in awaiting_factcheck state
    And I see the transition to the awaiting_factcheck state in the timeline
    And I see the details of the review outcome in the timeline
    And the calls to action are suited to the awaiting_factcheck state

  Scenario: Attempt to send to factcheck without supplying review outcome
    Given I am viewing the edition awaiting review
    Then I see a principal call to action of 'Send to factcheck'

    When I opt to send the edition to factcheck
    And I attempt to proceed without supplying the outcome of the review process
    Then I see that I need to indicate whether the review process was performed or skipped

  Scenario: Attempt to make an invalid transition to 'ready_for_factcheck'
    Given I am viewing the edition awaiting review
    And I see a principal call to action of 'Send to factcheck'

    Given the edition has been put into the awaiting_factcheck state by another process
    And I opt to send the edition to factcheck
    And I provide the outcome of the review process
    Then I see an alert that the transition failed to transition to awaiting_factcheck
