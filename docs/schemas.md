# Content Block Schemas

## Anatomy of a schema

All content block types are managed in the schemas within the [Schema definitions directory](https://github.com/alphagov/content-block-manager/tree/main/app/models/schema/definitions).

Schemas are picked up by Content Block Manager via the [`Schema` class](https://github.com/alphagov/content-block-manager/blob/main/app/models/schema.rb).

When creating a new content block, we fetch all the supported schemas and give the user a list of valid block types to
create. Once a block type is chosen the form is then populated using all the fields within a schema's `details` object
(apart from embedded objects, more on this later), as well as the title, lead organisation and instructions to publishers.

All fields within `details` generate a standard input field by default. If a schema has an `enum` type, this generates
a select field populated with the valid enum values. It is also possible to use custom input fields. See the
[configuration section](configuration.md) for more information.

### Embedded objects

Schemas can also have embedded objects. Embedded objects are objects that are nested within a schema's root object. They
can have a one-to-many or one-to-one relationship to the root object.

If any embedded objects are included, a user can create these objects on a separate screen after creating the initial
object.

A one-to-one embedded relationship is defined as a regular JSON object.

A one-to-many embedded relationship is defined as a JSON object that uses `patternProperties`, where each key must
match a slug format (see the [Pension schema](https://github.com/alphagov/content-block-manager/blob/main/app/models/schema/definitions/pension.json#L11)
for an example).

For example, the Pension schema defines `rates` as a one-to-many embedded object:

```json
"rates": {
  "type": "object",
  "additionalProperties": false,
  "patternProperties": {
    "^[a-z0-9]+(?:-[a-z0-9]+)*$": {
      "type": "object",
      "required": ["amount", "frequency"],
      "additionalProperties": false,
      "properties": {
        "title": { "type": "string" },
        "amount": { "type": "string" },
        "frequency": { "type": "string" },
        "description": { "type": "string" }
      }
    }
  }
}
```

And an example `rates` payload looks like this:

```json
"rates": {
  "rate-1": {
    "title": "Rate 1",
    "amount": "£221.20",
    "frequency": "a week",
    "description": "Your weekly pension amount"
  },
  "rate-2": {
    "title": "Rate without decimal point",
    "amount": "£221",
    "frequency": "a week",
    "description": "Your weekly pension amount"
  },
  "rate-3": {
    "title": "Rate with big value",
    "amount": "£1,223",
    "frequency": "a week",
    "description": "Your weekly pension amount"
  }
}
```

Each item key is automatically generated from the title (for example, `Rate 1` becomes `rate-1`). The key is immutable,
so changing the title later does not change the key.

### Currently supported schemas

There are currently 4 supported schemas in Content Block Manager:

- [Contacts](https://github.com/alphagov/content-block-manager/blob/main/app/models/schema/definitions/contact.json)
- [Pensions](https://github.com/alphagov/content-block-manager/blob/main/app/models/schema/definitions/pension.json)
- [Taxes](https://github.com/alphagov/content-block-manager/blob/main/app/models/schema/definitions/tax.json)
- [Time Periods](https://github.com/alphagov/content-block-manager/blob/main/app/models/schema/definitions/time_period.json)

### Adding a new schema

[Instructions on how to add a new schema can be found here](adding_a_new_schema.md)
