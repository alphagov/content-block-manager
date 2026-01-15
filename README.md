# Content Block Manager

Content Block Manager is used by publishers to create and manage reusable content blocks.

A content block is a discrete piece of information such as contact details that can be embedded within 
multiple pages. When a single block is updated, all documents with it embedded are automatically updated,
therefore reducing duplication of work and ensuring consistency across locations.

This README is for developers using content-block-manager, to view publisher documentation navigate to:
[Content Block Manager Publisher Docs](https://www.gov.uk/guidance/how-to-publish-on-gov-uk/content-block-manager).

## Running the Application

Use [GOV.UK Docker](https://github.com/alphagov/govuk-docker) to run any commands that follow.

If you want to run the application with Whitehall, Publisher, Content Store and the frontend apps running (allowing
you to test the whole publishing stack, as well as previewing content):

__Note: you need to run the fullstack the first time you run the app to allow it to set up the dbs correctly__

```bash
govuk-docker run content-block-manager-full
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

### Further documentation

See the [`docs/`](docs/) directory.

## Licence

[MIT License](LICENCE)

## Contact

The Content Modelling Team are available via Slack at [#govuk-publishing-content-modelling-dev](https://gds.slack.com/archives/C0776B04EJU)
