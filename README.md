# Content Block Manager

Content Block Manager is used by publishers to create and manage reusable content blocks.

A content block is a discrete piece of information such as contact details that can be embedded within 
multiple pages. When a single block is updated, all documents with it embedded are automatically updated,
therefore reducing duplication of work and ensuring consistency across locations.

This README is for developers using content-block-manager, to view publisher documentation navigate to:
[Content Block Manager Publisher Docs](https://www.gov.uk/guidance/how-to-publish-on-gov-uk/content-block-manager).

## Block Picker Demo

There is a built in demo of the block picker that can be used to test the block picker functionality. To run the demo, run the application and navigate to: /content-block-picker-demo

Currently, the NPM bundling for CBP is broken, so we pull the code directly from GitHub. Yarn caches very efficiently, so if you have previously run the demo, you may need to clear your yarn cache to get the latest version of the code. You can do this by running:

### When running in govuk docker

```bash
govuk-docker run content-block-manager-app yarn install
govuk-docker run content-block-manager-app rake assets:precompile
```

### When running locally

```bash
yarn cache clean
yarn install --check-files
rake assets:precompile
```

## Running the Application

Use [GOV.UK Docker](https://github.com/alphagov/govuk-docker) to run any commands that follow.

If you want to run the application with Whitehall, Publisher, Content Store and the frontend apps running (allowing
you to test the whole publishing stack, as well as previewing content):

__Note: you need to run the fullstack the first time you run the app to allow it to set up the dbs correctly__

```bash
bin/full-stack
```

To run the just the application:

```bash
govuk-docker run content-block-manager-app
```

When running the app in docker like this the local development url is: `http://content-block-manager.dev.gov.uk/?lead_organisation=`

### Initial database setup

If you run into issues using the application you might need to manually create and migrate the db.

Run:

```bash
govuk-docker run content-block-manager-app bundle exec rails db:create
govuk-docker run content-block-manager-app bundle exec rails db:migrate
```

or run the combined:
```bash
govuk-docker run content-block-manager-app bundle exec rails db:prepare
```

The run:

```bash
govuk-docker run content-block-manager-app bundle exec rails db:seed
```

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

### Running the test suite

These commands assume you have the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) running and its binaries in your PATH. 

> To enable the feature tests to load the schemas for content blocks , you must ensure you have Publishing API checked 
out in the parent directory (i.e. `../publishing-api`). The easiest way to do this is by running `make publishing-api` 
within the `./govuk-docker` directory.

```
# run all the test suites
govuk-docker-run bundle exec rake
```

Javascript unit tests can also be run separately:

```
# run all the JavaScript tests
govuk-docker-run bundle exec rake jasmine
```

If you want to run the feature tests with a live browser (handy for debugging), then you can run:

```bash
HEADLESS=false bundle exec cucumber
```

NOTE: As this is running outside of the GOV.UK Docker environment, you will need a local database and Redis set up
and running.

### Linting and formatting

To run all linters, run:

```bash
bundle exec rake:lint
```

To run all linter with automatic formatting corrections, run:

```bash
bundle exec rake:lint_autocorrect
```

### API

The code for the API is in the [`engines/api`](engines/api) directory. It is a Rails engine, and uses 
[`rswag`](https://github.com/rswag/rswag) to generate [OpenAPI documentation](engines/api/swagger) from the tests in 
[`engines/api/spec/requests`](engines/api/spec/requests).

If you make any changes to the API, then you can regenerate the OpenAPI documentation by running:

```
rake api:generate_swagger
```

This will then update the OpenAPI documentation in [`engines/api/swagger`](engines/api/swagger).

### Further documentation

See the [`docs/`](docs/) directory.

## Licence

[MIT License](LICENCE)

## Contact

The Content Reuse Team are available via Slack at [#govuk-publishing-content-reuse-dev](https://gds.slack.com/archives/C0776B04EJU)
