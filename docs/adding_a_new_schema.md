# Adding a new schema

To add a new content block schema, follow the instructions below:

## Add the new type to Content Block Manager

Schemas are defined in the [Schema definitions directory](https://github.com/alphagov/content-block-manager/tree/main/app/models/schema/definitions)
in a JSON schema format.

This represents the shape of the data which will be stored in a content block's `details` field.

Once the schema is defined, you must define it as a supported schema in the
[`VALID_SCHEMAS` constant within the Schema class](https://github.com/alphagov/content-block-manager/blob/main/app/public/models/schema.rb#L4)
so that it can be used in Content Block Manager.

Schemas can be defined as `live` or `alpha`. `live` schemas are visible in production, and can be accessed by anyone.
`alpha` schemas are only visible in integration/staging or for users with the `SHOW_ALL_CONTENT_BLOCK_TYPES` role
in production.

## Add tests for the new schema

You should add tests for the new schema in the [Schema tests directory](https://github.com/alphagov/content-block-manager/tree/main/spec/unit/app/validators/details_validator),
following the pattern of the existing tests. If the schema has specific validation rules, ensure these are covered too.

## Add any customisations

There is a [config file](https://github.com/alphagov/content-block-manager/blob/main/config/content_block_manager.yml)
which allows you to configure how the schema is presented in Content Block Manager.

[See all available configuration variables](configuration.md)

## Open a pull request

Once these changes are made, open a pull request to Content Block Manager and get these changes approved

## Add support to Content Block Tools

Once the block is added to Content Block Manager, you must define it as a supported content block in the
[Content Block Tools gem](https://github.com/alphagov/govuk_content_block_tools).

Supported content blocks are defined in the [`SUPPORTED_DOCUMENT_TYPES` constant within the `ContentBlockReference` class](https://github.com/alphagov/govuk_content_block_tools/blob/main/lib/content_block_tools/content_block_reference.rb#L31).

If there are any custom behaviours required for a content block, you can also add a component to the
[Content Block Tools gem](https://github.com/alphagov/govuk_content_block_tools).

You can see [an example component here](https://github.com/alphagov/govuk_content_block_tools/blob/main/app/components/content_block_tools/contact_component.rb).
