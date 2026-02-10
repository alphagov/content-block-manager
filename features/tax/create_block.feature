@javascript
Feature: Create Tax Content Block

  Background:
    Given I am logged in
    And the organisation "Ministry of Example" exists
    And the schema "tax" exists
    And I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "tax" schema

  Scenario: Editor can create a tax content block
    When I complete the form with the following fields:
      | title           | abbreviation   | synonym | tax_type | note      | description      | organisation        | instructions_to_publishers |
      | Value Added Tax | VAT            | VAT     | Tax      | Some note | Some description | Ministry of Example | This is important          |
    When I click to add a new "thing_taxed"
    And I complete the "thing_taxed" form with the following fields:
      | title                   | type        | rates_0_name  | rates_0_value |
      | Most goods and services | Transaction | Standard Rate | 20%           |
    And I save and continue
    And I review and confirm I have checked the content
    Then I should be taken to the confirmation page
    And the block should have been sent to the Publishing API
    When I click to view the content block
    Then I should see the details for the tax content block
    Then I should see the details for each thing_taxed's rate

  Scenario: Editor can create a tax content block with bands and thresholds
    When I complete the form with the following fields:
      | title      | tax_type | note      | description      | organisation        | instructions_to_publishers |
      | Income tax | Tax      | Some note | Some description | Ministry of Example | This is important          |
    When I click to add a new "thing_taxed"
    And I fill in the "thing_taxed" form with the following fields:
      | title  | type   | rates_0_name       | rates_0_value |
      | Income | Income | Personal Allowance | 0%           |
    And I click to add a "band"
    And I fill in the "thing_taxed" form with the following fields:
      | rates_0_bands_0_name    |
      | Personal allowance band |
    And I tick to show the upper threshold
    And I fill in the "thing_taxed" form with the following fields:
      | rates_0_bands_0_upper_threshold_value |
      | £12,570                               |
    And I click to add another "rate"
    And I fill in the "thing_taxed" form with the following fields:
      | rates_1_name       | rates_1_value |
      | Standard Rate      | 20%           |
    And I click to add a "band"
    And I fill in the "thing_taxed" form with the following fields:
      | rates_1_bands_0_name |
      | Standard Rate band   |
    And I tick to show the lower threshold
    And I tick to show the upper threshold
    And I complete the "thing_taxed" form with the following fields:
      | rates_1_bands_0_lower_threshold_value | rates_1_bands_0_upper_threshold_value |
      | £12,571                               | £50,270                               |
    And I save and continue
    And I review and confirm I have checked the content
    Then I should be taken to the confirmation page
    When I click to view the content block
    Then I should see the details for the tax content block
    Then I should see the details for each thing_taxed's rate
