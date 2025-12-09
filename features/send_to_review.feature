Feature: Editor sends edition to Review
  - So that I can get feedback from a 2nd pair of eyes before publishing
  - As an editor who has prepared a new (or first) edition of a block
  - I want my edition to go into an `awaiting_review` state after `draft` and en route
    to becoming ultimately `published`

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
    And a pension content block has been drafted

  Scenario: Send to '2i' Review from block show page
    Given the draft workflow has been completed
    When I visit the Content Block Manager home page
    And I click to view the document
    Then I see that the edition is in draft state
    And I see a principal call to action of 'Send to 2i'
    And I see a secondary call to action edit the existing draft

    And I opt to send the edition to Review
    Then I see a notification that the transition to awaiting_review was successful
    And I see that the edition is in awaiting_review state
    And I see the transition to the awaiting_review state in the timeline
    And the calls to action are suited to the awaiting_review state

  Scenario: Attempt to make an invalid transition to 'ready_for_review'
    Given the draft workflow has been completed
    And I visit the Content Block Manager home page
    And I click to view the document
    Then I see that the edition is in draft state
    And I see a principal call to action of 'Send to 2i'

    Given the document has been put into the awaiting_review state by another process
    And I opt to send the edition to Review
    Then I see an alert that the transition failed to transition to awaiting_review

  Scenario: No option to 'Send to review' when draft is unchecked
    Given the draft workflow has not been completed
    And I am viewing the draft edition
    Then I do not see a call to action of 'Send to 2i'
    And I see a principal call to action to complete the draft

  Scenario: Send to 2i Review from review step in workflow
    When I visit the Content Block Manager home page
    And I click to view the document
    Then I see that the edition is in draft state

    When I follow the link to complete the draft
    Then I see that I can complete the workflow with 'Send to 2i'

    When I confirm I have checked the content
    And I opt to send the edition to Review
    Then I see a notification that the transition to Awaiting 2i was successful
    And I see that the edition is in awaiting_review state
    And the calls to action are suited to the awaiting_review state

  Scenario: Must confirm that contents are checked before going from workflow to 2i Review
    Given I am on the draft's workflow review step
    And I try to send the draft to review without confirming that I have checked the contents
    Then I should see a message that I need to confirm the details are correct