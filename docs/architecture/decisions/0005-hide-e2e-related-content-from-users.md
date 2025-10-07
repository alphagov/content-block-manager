# 5. Hide E2E related content from users

Date: 2025-09-15

## Status

Accepted

## Context

We have two suites of End-to-End tests for the project:

- The [GOV.UK End-to-End tests](https://github.com/alphagov/govuk-e2e-tests) - which are run automatically after deployment to the integration and staging 
environments; and
- The [Content Modelling End-to-End tests](https://github.com/alphagov/content-modelling-e2e) - which are run manually.

The GOV.UK End-to-End tests are quick smoke tests that use a test block that exists in all environments (called 
"Test Content Block - Do Not Use"), it then copies the block's embed code and attempts to use it in two draft test 
documents in Whitehall and Mainstream. Nothing here is published, as the tests are run in production too.

The Content Modelling End-to-End tests are more comprehensive and follow the complete lifecycle of a content block, 
from creation, to publishing, through to use in a document (in both Whitehall and Mainstream) and the update of a value.

In both of these circumstances, we do create a bit of noise for users:

- For the GOV.UK tests, we have a block that we say users shouldn't use, and;
- for the Content Modelling tests, we create new blocks for each test run.

Usually this isn't too much of a problem because the Integration environment is cleaned up every Monday, and the staging
environment is cleaned up every day.

However, recently, a decision has been made to disable the Integration and Staging environment refreshes temporarily,
which means there are a lot of stale blocks in the environments. As the Integration environment is going to be used
shortly by real users, we need to cut down on the noise for users.

This is complicated by the fact that (by design) it's not possible to delete a block from Content Block Manager via the
UI. It is a developer task (see [Deleting a content block](https://github.com/alphagov/content-block-manager/blob/main/docs/deleting_a_content_block.md)), 
but this would be a challenging (and risky) thing to automate as part of the E2E tests.

## Decision

We have decided that we should hide any blocks that are created by or for the End-to-End tests for real users. We will
do this by adding a new field to the `Document` model, `testing_artefact`, which will be set to `true` for any 
documents that are created by or for the End-to-End tests.

In order for this to happen, we will need to add a comma seperated `E2E_USER_EMAILS` environment variable to the application. 
If any user with one of these email addresses creates a block, then we set the `testing_artefact` field to `true`.

We did consider adding a new field to the `User` model, but decided against it as when the integration and staging 
environments are refreshed, the `User` records are deleted and recreated, so we would need to update the `User` records
for all users in the environments each time.

Adding the field to the `Document` model also means that we don't need to add a join to the `User` model when querying 
for documents that are created by or for the End-to-End tests.

## Consequences

We will need to add the `E2E_USER_EMAILS` environment variable to the application via the GOV.UK Helm charts. These are not
secrets as such, so can be added in plain text.

Once this is done, there will still be some E2E blocks that do not have this boolean field set, so we will need to 
manually update them. We will do this via a Rake task instead of on the console as this is safer and more testable. 
We can run the task manually and then delete the code once it has been run in all environments.

This also gives us the flexibility to run the Content Modelling E2E tests more often (such as on a schedule,
or after a deployment to integration or staging), because the risk of adding noise to the application will be lowered.
