# 17. Enhance the Content Block Manager API

Date: 2026-09-11

Status: Proposed

## Context

ADR 13 introduced a Content Block Manager API to support content block discovery and rendering for publishing applications and editor tooling. In practice, the API has been used for two distinct concerns:

- searching for blocks and returning metadata (`GET /api/blocks`)
- rendering HTML for one embed code at a time (`GET /api/blocks/*embed_code/render`)

As adoption has started, this split has become more important. Consumers need to discover candidate blocks from embed-code-based queries without also fetching rendered HTML, and they need a separate rendering capability that can operate efficiently over multiple embed codes.

### Current behaviour and constraints

The search endpoint at `GET /api/blocks` is currently used by existing consumers and must remain available at this path for backward compatibility.

Embed codes currently used by consumers include:

- a base block reference: `embed:content_block_TYPE:NAME`
- a format-specific reference: `embed:content_block_TYPE:NAME#FORMAT`

Historically, embed codes could also include internal field paths (`/path`), but that usage is now deprecated and is out of scope for the enhanced API behaviour in this ADR. For the purposes of search and matching, the base embed code excludes any internal path segment.

When a block is matched via its base embed code, consumers also need to know which formats are supported so they can construct valid format-specific embed codes.

### Needed API shape

We need to formalise a three-endpoint model:

1. `GET /api/blocks` remains the search endpoint and returns block metadata, keyed around matching by base embed code, including a list of supported formats for each matched block.
2. `GET /api/blocks/*embed_code/render` continues to return rendered HTML for a single embed code and supports both default and `#FORMAT` embed codes. This endpoint may be deprecated in around three months because its only consumer is owned by the content reuse team.
3. A new `POST` render endpoint accepts a list of embed codes (with or without `#FORMAT`) and returns both rendered HTML and metadata for each requested value. The response is keyed by the input embed code to support deterministic consumer lookups.

### Versioning approach

API versioning is handled through media-type negotiation via request headers (for example, `Accept: application/vnd.govuk.v1+json`) rather than versioned URL paths such as `/api/v1/...`. Any enhancement described in this ADR must fit that versioning model.

## Decision

We will evolve the API into a clear discovery-and-render contract while preserving compatibility for existing consumers.

### 1. Keep `GET /api/blocks` as the search endpoint

- The endpoint path remains `GET /api/blocks`.
- API versioning continues via media type in the `Accept` header (for example, `Accept: application/vnd.govuk.v1+json`).
- Search responses must retain existing fields (`title`, `block_type`, `organisation`, `state`, `embed_code`, `formats`). New fields may be added, but existing fields must not be removed.
- Search matching is based on the **base embed code** form: `embed:content_block_TYPE:NAME`.
- Internal field paths (`/path`) are deprecated and not part of the search model.

Sample request:

```http
GET /api/blocks?embed_code=embed:content_block_time_period:tax-year HTTP/1.1
Accept: application/vnd.govuk.v1+json
```

Sample response:

```json
{
  "results": [
    {
      "title": "Tax year",
      "block_type": "Time period",
      "organisation": {
        "name": "HM Revenue & Customs",
        "content_id": "6667cce2-e809-4e21-ae09-cb0bdc1ddda3"
      },
      "state": "published",
      "embed_code": "{{embed:content_block_time_period:tax-year}}",
      "formats": [
        "long_form",
        "months_and_years_long",
        "start_day_and_month",
        "start_month_as_word",
        "years",
        "years_short"
      ]
    }
  ]
}
```

### 2. Continue supporting single render via `GET /api/blocks/*embed_code/render`

- The endpoint remains available for now.
- It renders one embed code per request.
- It supports default embed codes and format-specific embed codes (`#FORMAT`).
- It may be deprecated after approximately 3 months, as its current consumer is owned by the content reuse team.

Sample request:

```http
GET /api/blocks/%7B%7Bembed%3Acontent_block_time_period%3Atax-year%23years_short%7D%7D/render HTTP/1.1
Accept: text/html
```

Sample response (`text/html`):

```html
<span class="content-block content-block--time_period" data-embed-code="{{embed:content_block_time_period:tax-year#years_short}}">2025-26</span>
```

### 3. Add batch render via `POST /api/blocks/render`

- A new POST endpoint will accept multiple embed codes in one request.
- Each embed code may be default (`embed:content_block_TYPE:NAME`) or format-specific (`embed:content_block_TYPE:NAME#FORMAT`).
- The response is keyed by the input embed code string to provide deterministic lookups.
- For each key, the API returns metadata plus rendered HTML.

Sample request:

```http
POST /api/blocks/render HTTP/1.1
Accept: application/vnd.govuk.v1+json
Content-Type: application/json
```

```json
{
  "embed_codes": [
    "{{embed:content_block_pension:new-state-pension}}",
    "{{embed:content_block_time_period:tax-year#years_short}}"
  ]
}
```

Sample response:

```json
{
  "rendered_blocks": {
    "{{embed:content_block_pension:new-state-pension}}": {
      "title": "New State Pension",
      "block_type": "Pension",
      "organisation": {
        "name": "Department for Work and Pensions",
        "content_id": "b548a09f-8b35-4104-89f4-f1a40bf3136d"
      },
      "state": "published",
      "embed_code": "{{embed:content_block_pension:new-state-pension}}",
      "formats": [],
      "html": "<div class=\"content-block content-block--pension\" data-embed-code=\"{{embed:content_block_pension:new-state-pension}}\">New State Pension</div>"
    },
    "{{embed:content_block_time_period:tax-year#years_short}}": {
      "title": "Tax year",
      "block_type": "Time period",
      "organisation": {
        "name": "HM Revenue & Customs",
        "content_id": "6667cce2-e809-4e21-ae09-cb0bdc1ddda3"
      },
      "state": "published",
      "embed_code": "{{embed:content_block_time_period:tax-year}}",
      "formats": [
        "long_form",
        "months_and_years_long",
        "start_day_and_month",
        "start_month_as_word",
        "years",
        "years_short"
      ],
      "html": "<span class=\"content-block content-block--time_period\" data-embed-code=\"{{embed:content_block_time_period:tax-year#years_short}}\">2025-26</span>"
    }
  }
}
```

## Consequences

### Backward compatibility is preserved for search

- Existing consumers of `GET /api/blocks` continue to work at the same path.
- The search response remains additive: existing fields are retained and new fields can be introduced without breaking clients.
- Clients that only need discovery can avoid unnecessary HTML rendering calls.

### Search is explicitly embed-code centric

- The API contract now centres on base embed codes (`embed:content_block_TYPE:NAME`) for search and matching.
- Deprecated internal field-path usage (`/path`) is no longer part of the intended integration model.
- Returning `formats` alongside each matched block enables clients to construct valid `#FORMAT` embed codes without schema-specific logic.

### Single-render GET remains available during transition

- `GET /api/blocks/*embed_code/render` continues to support one-at-a-time rendering for default and `#FORMAT` embed codes.
- Because the only known consumer is owned by the content reuse team, we can run a time-boxed deprecation process (around three months) with direct coordination.
- The deprecation timeline should include communication, usage verification, and a final removal decision point.

### Batch rendering reduces integration and performance costs

- `POST /api/blocks/render` enables clients to resolve multiple embed codes in one round trip.
- Responses keyed by input embed code simplify consumer correlation and reduce client-side mapping logic.
- Returning metadata and HTML together allows publish-time and preview-time pipelines to perform a single lookup per embed code.

### Error handling must be predictable for batch consumers

- Batch responses will need a stable approach for mixed outcomes (for example, some embed codes rendering successfully while others fail).
- Error representation per input key should be explicit so clients can retry or surface validation feedback without ambiguity.
- The same expectations should be reflected in OpenAPI examples and request specs.

### Versioning remains header-based

- Changes are introduced under media-type versioning (`Accept: application/vnd.govuk.v1+json`), not path versioning.
- Future breaking changes require a new media type version rather than introducing `/api/vN/...` route variants.
- Documentation and consumer guidance must continue to treat the `Accept` header as the source of version selection.
