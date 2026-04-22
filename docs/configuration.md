# Configuration

Configuration for content blocks is stored in the schema definition files under `app/models/schema/definitions/*.json`.

## Where configuration lives

Each block type has a JSON schema file, for example:

- `app/models/schema/definitions/contact.json`
- `app/models/schema/definitions/pension.json`
- `app/models/schema/definitions/tax.json`
- `app/models/schema/definitions/time_period.json`

These files define both:

- the JSON schema shape (`type`, `properties`, `required`, `patternProperties`, etc)
- Content Block Manager UI metadata using `x-*` extension keys

## Supported schema metadata (`x-*` keys)

### Block/subschema-level keys

- `x-embeddable-as-block`: whether an object/subschema can be embedded as a standalone block
- `x-block-display-fields`: fields omitted from metadata summary and displayed in the block body
- `x-field-order`: field ordering for forms and summary metadata
- `x-group`: logical group name for grouped subschemas (for example, contact methods)
- `x-group-order`: ordering within a group

### Field-level keys

- `x-component-name`: override the component used to render a field
- `x-character-limit`: soft character limit shown in the UI (used with textarea-like components)
- `x-govspeak-enabled`: enables Govspeak support for a field
- `x-show-field-name`: nested toggle field used for conditional reveal of object fields
- `x-hidden-field`: marks a field as hidden in the form

## Examples

### Component, character limit and Govspeak

```json
"description": {
  "type": "string",
  "x-component-name": "textarea",
  "x-character-limit": 165,
  "x-govspeak-enabled": true
}
```

### Conditional reveal (`x-show-field-name`) and hidden toggle field (`x-hidden-field`)

```json
"opening_hours": {
  "type": "object",
  "x-show-field-name": "show_opening_hours",
  "properties": {
    "show_opening_hours": {
      "type": "boolean",
      "x-hidden-field": true,
      "default": false
    },
    "opening_hours": {
      "type": "string",
      "x-component-name": "textarea"
    }
  }
}
```

### Field ordering

```json
"x-field-order": ["title", "description", "telephone_numbers", "video_relay_service"]
```

## Notes

- Prefer adding or changing schema metadata in `app/models/schema/definitions/*.json`.
- If a metadata key is missing, rendering falls back to default behavior in the model layer.
