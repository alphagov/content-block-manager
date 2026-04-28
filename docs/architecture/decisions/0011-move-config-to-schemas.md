# 11. Move content block configuration into schemas

Date: 2026-04-27

Status: Accepted

## Context

In [ADR 0010](0010-make-content-block-manager-the-source-of-truth-for-schemas.md), we agreed that Content Block Manager 
should become the source of truth for schema definitions.

We made this change but, behaviour was split across two places:

- schema structure in `app/models/schema/definitions/*.json`
- UI and rendering configuration in `config/content_block_manager.yml`

That split made the system harder to maintain:

- configuration could drift from the schema it applied to
- contributors had to update multiple files for one behaviour change
- it was harder to understand a block type in one read

## Decision

We moved configuration into each schema definition file and removed `config/content_block_manager.yml`.

We now store configuration as schema extension properties using the `x-` prefix. This follows a common JSON Schema 
convention for non-standard annotations.

## Consequences

- One source of truth per block type: structure and behaviour are co-located.
- Faster and safer schema changes, because edits happen in one file.
- Lower risk of mismatch between what a schema allows and how it is rendered.
- Simpler onboarding: contributors can inspect a schema file to understand both validation and UI behaviour.

This will also allow us to investigate moving towards a simpler JSON definition format, rather than using JSON Schema.
This will make the system easier to maintain and understand, as well as simplifying the code.
