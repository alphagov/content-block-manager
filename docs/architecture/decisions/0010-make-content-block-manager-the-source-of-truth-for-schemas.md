# 10. Make Content Block Manager the source of truth for schemas

Date: 2026-02-12

Status: Accepted

## Context

### Current State

Currently, schemas for the Content Block Manager are stored in the Publishing API. This allows the Publishing API to 
validate content shape upon receipt. The Content Block Manager also consumes these schemas to dynamically build form 
interfaces.

### The Problem

This architecture creates several friction points:

1.  **Coupled Deployments:** Modifying a block type requires coordinated changes in both the Publishing API and the 
Content Block Manager.
2.  **Split Configuration:** Schema definitions live in the API, while block configuration lives in the Content Block 
Manager (YAML), creating two sources of truth.
3.  **Outdated Validation Logic:** The Publishing API uses the [json-schema][1] gem, which lags behind the latest 
specifications. Specifically, we are introducing a "Time Period" block that requires date validation, which the API's 
gem does not support.

Conversely, the Content Block Manager uses the [json_schemer][4] gem, which is actively maintained and supports the 
modern validation features we need.

## Decision

We will shift schema ownership from the Publishing API to the Content Block Manager.

### Strategy

We will adopt an **incremental migration strategy** rather than a "big bang" approach, starting immediately with the 
new "Time Period" block.

### Implementation Details

1.  **Content Block Manager (Primary Validator):**

    *   Will store schemas locally as JSON files.
    *   Is solely responsible for validating the complex `details` hash of a block (with optional custom validation).

2.  **Publishing API (Metadata Validator):**

    *   Will use a generic `content_block` schema.
    *   Is responsible for validating standard metadata, including:
        *   `title`
        *   `base_path`
        *   `instructions_to_publishers`
        *   `edition_links` (e.g., `primary_publishing_organisation`)
    *   Will accept *any* structure within the `details` hash, trusting that Content Block Manager has already 
    validated it.

## Consequences

*   **Hybrid Schema Fetching:** During the transition, the `Schema` object must support fetching schemas from both the 
Publishing API (legacy) and local files (new).
*   **Presenter Logic:** The `ContentBlockPresenter` must be updated to inject the generic `content_block` schema name 
when sending locally-defined blocks to the API.
*   **Cleanup:** Once all block types are migrated, the temporary fetching logic can be removed.

## Future Plans

*   **Config Consolidation:** Move configuration currently housed in `config/content_block_manager.yml` directly into 
the JSON schemas to create a single source of truth.
*   **Advanced Validation:** Leverage the newer gem capabilities to implement complex checks, such as date range 
validation.

[1]: https://github.com/voxpupuli/json-schema
[2]: https://json-schema.org/draft-07
[3]: https://json-schema.org/draft-07/draft-handrews-json-schema-validation-01#rfc.section.7.3.1
[4]: https://github.com/davishmcclurg/json_schemer
