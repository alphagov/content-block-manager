# End-to-end tests

Content Block Manager has two suites of end-to-end tests.

The first suite is contained within the wider [GOV.UK E2E Tests repo][1] and runs after each deploy in the integration,
staging and production environments. If the test fails, it prevents deployment to any subsequent environment. For
example, if integration fails, then staging does not deploy, and if staging fails, then production does not deploy.

The second suite is contained within [our own repo][2] and is designed to ONLY run in integration and production.
Currently, this suite of tests is only run on demand.

Both suites use [Playwright][3] under the hood.

## GOV.UK E2E tests

These tests are designed to be as light touch as possible, and, because they run in production, they ONLY
run on draft content. There is a [Test block][4] and a [Test Whitehall Document][5] and [Test Mainstream Document][6]
in existence in all three environments.

The tests do the following:

- Get an embed code from the test block
- Insert the embed code into the test documents
- Make a change to the block
- Confirm this change appears on both test documents

Note that the test content block (id: 18) is only visible to the E2E test user (`SIGNON_EMAIL`)

### Help! The E2Es have failed

#### View logs and reproduce locally

- go to the Argo **Workflows** (as distinct from Argo **CD**) at `https://argo-workflows.eks.{environment}.govuk.digital/workflows/apps/`
- identify a failed `gov-e2e-tests` workflow node
- view the logs to understand the error

If you want to run the tests locally against a given environment to reproduce the error
and debug, you should be able to do that by temporarily setting the credentials locally e.g.:

```sh
PUBLISHING_DOMAIN=integration.publishing.service.gov.uk
PUBLIC_DOMAIN=www.integration.publishing.service.gov.uk
DGU_DOMAIN=www.integration.data.gov.uk

SIGNON_EMAIL=REDACTED
SIGNON_PASSWORD=REDACTED
```

You can pull the credentials from the `secretmanager` and set them as transient environment variables with a command
like:

```sh
source <(aws secretsmanager get-secret-value --secret-id govuk/content-block-manager/e2e-secrets | \
  jq -r '.SecretString | fromjson | to_entries[] | "export \(.key)=\(.value); echo Set: \(.key)"')

```

or in the `fish` shell with:

```sh
aws secretsmanager get-secret-value --secret-id govuk/content-block-manager/e2e-secrets | \
  jq -r '.SecretString | fromjson | to_entries[] | "set -x \(.key) \(.value); echo Set: \(.key)"' | \
  source
```

Run our CBM tests:

`yarn playwright test tests/content-block-manager.spec.js`

or with the Playwright interactive UI:

`yarn playwright test --ui tests/content-block-manager.spec.js`

#### Check infrastructure and fixtures

We're aware there is _some_ degree of flakiness in the tests, particularly in non-production environments. This is
because the integration and staging environments have a lot of churn with data being dropped and restored on a schedule.

If the tests fail for any reason, then there are a couple of things you can try. First of all, ensure you are logged
into the AWS environment for the appropriate environment (`integration` or `staging`):

```bash
eval $(gds aws govuk-integration-developer -e --art 8h)
kubectl config use-context govuk-integration
```

##### 1. Check the Publishing API queues

The first thing to do is check to see if the Publishing API queues are busy. Sometimes, if a lot of content is queued
for publication, this means that changes don't get reflected quickly enough, and the tests fail.

To do this, first forward the Sidekiq ports to access the Publishing API Sidekiq Web UI:

```bash
kubectl -n apps port-forward deployment/publishing-api 8080:8080
```

Then access <http://localhost:8080/sidekiq> in your browser.

If the number of queued jobs is high, keep an eye on this number, and retry the tests by clicking "Resubmit" in Argo
once the queue has calmed down.

##### 2. Reset the `payload_version` of all Content Items in the Draft Content Store

Sometimes, the payload versions of items in Content Store can get out of whack. This means that when Publishing API
tries to send content to the Content Store, it gets rejected, as Content Store thinks the version of the document is
out of date.

To confirm this, take a look at the logs in the appropriate environment and see if there are any entries that
contain a message in the format: `Tried to process request with payload_version $num, but the latest ContentItem has a
newer (or equal) payload_version of $num`:

```bash
kubectl logs -l app=publishing-api-worker | grep "Tried to process request with payload_version"
```

If this is the case, then we can reset the payload versions in the draft content store.

First, log into the Rails console for the **Draft** Content Store:

```bash
kubectl exec -it deploy/draft-content-store -- rails c
```

Then run the following to update the `payload_version`s for all content:

```ruby
ContentItem.update_all(:payload_version => 0)
```

Once this has run (it will take a couple of minutes), you can then try again by clicking "Resubmit" in Argo.

##### 3. Delete the locked jobs

Publishing API uses [sidekiq-unique-jobs][6] to ensure duplicate jobs are not queued. Sometimes this misbehaves in
non-prod environments, and jobs that shouldn't be locked get locked.

To solve this, forward the Sidekiq ports as mentioned earlier, then access <http://localhost:8080/sidekiq/locks>
and click `Delete all` to delete all the locked and stale jobs.

##### 4. Resubmit and observe

If the issue was with the test fixtures or infrastructure:

- re-submit the Argo **workflow** at `https://argo-workflows.eks.{environment}.govuk.digital/workflows/`

- observe the app being promoted through to production in:

  - Argo **CD** (as distinct from Argo workflow): `https://argo.eks.{environment}.govuk.digital/applications/cluster-services/content-block-manager`
  
  - Releases: `https://release.publishing.service.gov.uk/applications/content-block-manager`

[1]: https://github.com/alphagov/govuk-e2e-tests/
[2]: https://github.com/alphagov/content-modelling-e2e
[3]: https://playwright.dev/
[4]: https://content-block-manager.integration.publishing.service.gov.uk/18
[5]: https://whitehall-admin.integration.publishing.service.gov.uk/government/admin/standard-editions/1658299
[6]: https://publisher.integration.publishing.service.gov.uk/editions/a3dc0cf7-00e4-4868-b0fd-2c33b4f47387
