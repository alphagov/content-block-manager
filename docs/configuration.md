# Configuration

There is a config file within Content Block Manager, which allows us to configure how schemas and subschemas are
handled and presented. The schema is defined as follows:

## `schemas`

Made up of one or more schemas, as defined by [`schemas.<schema_name>`](#schemasschema_name)

## `schemas.<schema_name>`

An object that defines a schema

### `schemas.<schema_name>.embeddable_as_block`

This defines if a subschema is embeddable as an entire block.

### `schemas.<schema_name>.field_order`

An array of strings that defines the order in which:

- fields appear when rendering the form
- properties are listed when viewing an embedded object in a summary list

### `schemas.<schema_name>.fields`

An object that configures fields in a schema

#### `schemas.<schema_name>.fields.<field_name>.component`

Allows the component used for the field to be overridden. For example, when specifying:

```yaml
...
fields:
  my_field:
    component:
      boolean
...
```

The [Boolean](https://github.com/alphagov/whitehall/blob/main/lib/engines/content_block_manager/app/components/content_block_manager/content_block_edition/details/fields/boolean_component.rb) component will be used.

#### `schemas.<schema_name>.fields.<field_name>.field_order`

If thew field is an array of objects, specifies an array of strings that defines the order that fields appear in when
rendering the subfields that can be contained in that field.

#### `schemas.<schema_name>.fields.<field_name>.data_attributes`

A key/value list of data attributes to return in the HTML that surrounds the component for a given field. This is
useful for providing Javascript modules or custom selectors.

### `schemas.<schema_name>.subschemas`

A list of [subschemas](#schemasschema_namesubschemassubschema_name) for a specific object

### `schemas.<schema_name>.subschemas.<subschema_name>`

An object that defines a subschema.

#### `schemas.<schema_name>.subschemas.<subschema_name>.block_display_fields`

An array of strings that defines which fields will be:

- omitted from the summary list of "metadata" and
- consequently be included in the block which follows.

In the example of a pension rate, we configure `amount` to be a `block_display_field` in
`config/content_block_manager.yml`:

```yml
content_block_pension:
  subschemas:
    rates:
      block_display_fields:
        - amount
```

In this way we cause `amount` to be left off the metadata summary list and included
in the representation of the subschema block:

![block_display_fields usage example](img/block_display_fields.png)

#### `schemas.<schema_name>.subschemas.<subschema_name>.field_order`

An array of strings that defines the order that fields appear in when rendering the form.

#### `schemas.<schema_name>.subschemas.<subschema_name>.group`

If provided, defines the "group" a subschema appears in when viewing a contact block. For example, if a subschema is in
a "group" called "modes" alongside other subschemas, it will be rendered like so:

![Subschema group example](img/group.png)

There will also be a button rendered above the tabbed view, allowing the user to add an item of a particular type
within that group. Taking the example above, clicking on "Add group" will show the following screen:

![Add a group item example](img/add_group.png)

#### `schemas.<schema_name>.subschemas.<subschema_name>.group_order`

If provided, defines the order that a field is listed in when rendering a group.
