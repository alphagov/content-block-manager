# Content Block Manager

Content Block Manager is used by publishers to create and manage "blocks" on content
that can be reused and kept up to date across various pieces of content.

## Running the Application

Use [GOV.UK Docker](https://github.com/alphagov/govuk-docker) to run any commands that follow.

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

### Running the test suite

These commands assume you have the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) running and its binaries in your PATH.

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
