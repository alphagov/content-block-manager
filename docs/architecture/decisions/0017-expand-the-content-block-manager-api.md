# 17. Expand the Content Block Manager API

Date: 2026-09-02

Status: Proposed

## Context

[ADR 13](./0013-add-an-api-for-content-block-manager.md) decided that Content Block Manager needed its own API, separate from the Content Store, to support 
search/discovery for the [Content Block Picker](https://github.com/alphagov/content-block-picker), to eventually 
replace [Content Block Tools](https://github.com/alphagov/govuk_content_block_tools) as the single source of truth for
rendering, and to support migrating blocks in from other applications (e.g. Whitehall contacts).

That ADR sketched two endpoints: `GET /api/blocks/search` and `POST /api/blocks/render`. What has actually been built
so far, in `engines/api/`, is a smaller first cut:

- `GET /api/blocks` (`Api::BlocksController#search`) — filters on `block_type`, `lead_organisation_id` and `keyword`
  only. No `state` filter, no pagination, no sorting options.
- `GET /api/blocks/*embed_code/render` (`Api::BlocksController#render_block`) — renders a single embed code per
  request, over GET, not the batch `POST` endpoint ADR 13 proposed.
- `Api::ApplicationController` is a bare `ActionController::API` with **no authentication**, so only published
  blocks are reachable (`Api::BlockPresenter` hardcodes `state: "published"`).
- The response shape omits fields ADR 13 anticipated, notably `url` and pagination metadata (`total`, `pages`,
  `current_page`, `links`).
- There's no API versioning (`/api/blocks`, not `/api/v1/blocks`), even though the generated OpenAPI spec
  (`engines/api/swagger/v1/swagger.json`) already labels itself `v1`.
- There's no way to **resolve** a specific format of a block, only to discover which formats exist and to render
  the default one. A block's embed code is `{{embed:content_block_TYPE:NAME#FORMAT}}` — the base embed code (no
  `#FORMAT`) identifies the block; the `#FORMAT` suffix selects one of the formats declared in its schema's
  `x-formats` (see [ADR 12](./0012-offer-alternate-presentations-with-formats.md)). `GET /api/blocks` already
  returns each block's available formats today (`Api::BlockPresenter` includes `formats: @block.formats`, e.g.
  `"formats":["long_form","months_and_years_long","start_day_and_month","start_month_as_word","years","years_short"]`
  for the `tax-year` time period block, `[]` for block types with no extra formats), so discovery isn't the gap.
  What's missing is retrieving a *specific* format outside of rendering: `render_block` accepts a `#FORMAT` suffix
  and returns HTML for that format, but there's no way to fetch a given format's underlying data, or to look up a
  single block (with its formats) without going via search.

This was a reasonable starting point, but it's now the limiting factor for the things ADR 13 justified the API's 
existence for:

- The authoring widget may need to preview **draft** blocks, filter by state, and resolve a specific format's data
  (not just its default-format render) — none of which the current API supports.
- Publishing apps doing mass republication need to resolve many embed codes in one request; today that means one
  HTTP round trip per embed code.
- [ADR 16](./0016-store-blocks-as-activerecord-models.md) is moving block storage from a generic `Document`/`Edition`/
  `details`-JSON model to explicit `Block::`-namespaced ActiveRecord models. The API's external contract needs to be
  stable enough to survive that migration.

Throughout this ADR, blocks are addressed by **embed code**, never by `content_id`. `content_id` is an internal
identifier; every consumer of this API — the widget, publishing apps — works in terms of embed codes, and the
existing search and render endpoints already identify blocks that way. `content_id` remains useful *inside* a
response body (e.g. to correlate with Publishing API), but it will not be a request parameter anywhere in this API.

This ADR records the decision to expand the API to close these gaps, and how.

## Decision

We will expand `engines/api` into a versioned API with a wider set of endpoints, authentication for non-public
data, and response payloads that match what ADR 13 originally specified. We'll build this incrementally, in the
order below, rather than as one large change.

### 1. Version the API now

Move existing routes under `/api/v1/`, keep the unversioned routes as aliases for one deprecation window, then
remove them. This avoids a breaking change later once external consumers (the widget, Whitehall) are live.

Deprecation window (to confirm with consumers):

- Alias start date: `TBD`
- Deprecation notice date: `TBD`
- Alias removal date: `TBD`

### 2. Widen `GET /api/v1/blocks` (search)

Add the parameters ADR 13 specified but the current implementation dropped:

- `state` (defaults to `published`; requires auth to request `draft` — see below)
- `page` / `per_page`
- `sort` (default: most recently created, as today)

Return the fuller response shape from ADR 13: `total`, `pages`, `current_page`, `links`, and per-block `url`,
alongside the existing `title`, `block_type`, `organisation`, `state`, `embed_code`, `formats`. `url` is derived
from the block's base embed code (see below), not from `content_id`.

Auth behaviour for search:

- `state=published` is public.
- `state=draft` without a valid bearer token returns `401 Unauthorized`.
- `state=draft` with a valid bearer token but insufficient permission returns `403 Forbidden`.

### 3. Add `GET /api/v1/blocks/*embed_code`

A block detail endpoint, addressed by embed code — consistent with how search results and the render endpoint
already identify blocks, and routed the same way `GET /api/blocks/*embed_code/render` already is today. This is
needed for the widget to preview a specific block (rather than only finding it via search), and for `url` in
search results to resolve to something.

This endpoint is also where format *resolution* lives (discovery of which formats exist is already covered by the
`formats` field on `GET /api/v1/blocks`, unchanged from today):

- The **base embed code** (`{{embed:content_block_TYPE:NAME}}`, no `#FORMAT`) returns the block's default-format
  detail, including the same `formats` list already returned by search, for consistency between the two endpoints.
- Appending `#FORMAT` (`{{embed:content_block_TYPE:NAME#FORMAT}}`) resolves that specific format and returns its
  data alongside the same block metadata — the read counterpart to the render endpoint, which already accepts a
  `#FORMAT` suffix but only ever returns rendered HTML, not the underlying data for that format.

Path-qualified embed codes (for internal field paths) are deprecated and are not part of this API contract.
This API resolves block-level embed codes, optionally with `#FORMAT`.

### 4. Replace single-embed-code render with batch `POST /api/v1/blocks/render`

As specified in ADR 13: accept `{ "embed_codes": [...] }`, return a `rendered_blocks` map keyed by embed code, each
with `title`, `block_type`, and `html` — plus an explicit error entry per embed code that can't be resolved (the
current 404-for-the-whole-request behaviour doesn't work for a batch). Each entry in `embed_codes` may include a
`#FORMAT` suffix, exactly as `render_block` already accepts today; this endpoint doesn't change format handling,
just batches it. This directly serves the mass-republication case ADR 13 flagged as a volume risk: one request
instead of N.

We will keep the existing single-embed-code `GET .../render` route for one deprecation window for any caller
already using it, then remove it.

### 5. Authentication for non-public data

`state=draft` (and eventually write access, e.g. for the Whitehall migration) needs auth; published search and
render stay open, matching ADR 13's original reasoning that published content is already public.

Rather than build a new mechanism, we'll extend the JWT pattern already used for the fact-check view ([ADR
8](./0008-allow-non-signon-users-to-access-fact-check-view-via-a-jwt.md)) from "one edition, one shareable link" to
a bearer token any authenticated caller can send on the `Authorization` header. This reuses the existing
`JWT_AUTH_SECRET`-based decode/validate path instead of introducing API keys or full OAuth, which ADR 13 left open
as options. If write endpoints are added later (see Out of scope), we'll revisit whether JWT scopes are sufficient
or whether Signon-backed OAuth is needed for per-user permissions.

### 6. Caching and resilience for mass republication

ADR 13 flagged that publishing apps republish all their documents at once, and that the render endpoint must cope
with the resulting spike. We will:

- Cache rendered block HTML keyed by `(embed_code, edition id)`, invalidated when the edition changes, so repeated
  renders of an unchanged block during a republish don't re-run rendering.
- Add rate limiting (e.g. `rack-attack`) in front of the API engine, scoped separately from the main app's request
  budget.
- Set `Cache-Control`/`ETag` on `GET` responses so conditional requests are cheap.

Operability baseline (initial stub, values to finalise before implementation):

- Render cache invalidation triggers: edition create/update/publish/unpublish/delete, schema version change, format set change.
- `rack-attack` limits for `/api/v1/*`: `TBD` requests/minute, burst `TBD`.
- `429` responses include `Retry-After` header.
- API SLO/error budget for external consumers: `TBD`.

### 7. Insulate the API from the ADR 16 migration

`Api::BlockPresenter` and `Api::BlocksController` should only ever depend on the `ContentBlock` facade
(`app/public/models/content_block.rb`) and `ContentBlock::Query`, never directly on `Document`/`Edition` or, later,
`Block::Document`/`Block::Edition`. As ADR 16 moves individual block types onto the new ActiveRecord models, the
facade is what absorbs that change, so the API contract in this ADR doesn't need to change in lockstep.

### 8. API contract stubs

The payloads below are placeholders to lock endpoint shape and error handling.

Conventions for all payloads in this section:

- Use `snake_case` keys.
- Keep the top-level `results` envelope for search responses.
- Represent `organisation` as an object with `name` and `content_id`.

#### 8.1 `GET /api/v1/blocks` (search)

Request query params (stub):

- `block_type`
- `lead_organisation_id`
- `keyword`
- `state` (`published` | `draft`)
- `page`
- `per_page`
- `sort`

Response payload (stub):

```json
{
  "total": "INTEGER",
  "pages": "INTEGER",
  "current_page": "INTEGER",
  "links": {
    "self": "/api/v1/blocks?page=PAGE&per_page=PER_PAGE",
    "next": null,
    "prev": null
  },
  "results": [
    {
      "title": "STRING",
      "block_type": "STRING",
      "organisation": {
        "name": "STRING",
        "content_id": "UUID"
      },
      "state": "STATE",
      "embed_code": "EMBED_CODE",
      "formats": ["FORMAT"],
      "url": "DETAIL_URL",
      "content_id": "UUID"
    }
  ]
}
```

#### 8.2 `GET /api/v1/blocks/*embed_code` (detail + format resolution)

Response payload (stub):

```json
{
  "title": "STRING",
  "block_type": "STRING",
  "organisation": {
    "name": "STRING",
    "content_id": "UUID"
  },
  "state": "STATE",
  "embed_code": "EMBED_CODE",
  "formats": ["FORMAT", "FORMAT", "FORMAT"],
  "content_id": "UUID",
  "resolved_format": "FORMAT_NAME_OR_DEFAULT"
}
```

#### 8.3 `POST /api/v1/blocks/render` (batch render)

Request payload (stub):

```json
{
  "embed_codes": ["EMBED_CODE","EMBED_CODE","EMBED_CODE","EMBED_CODE"]
}
```

Response payload (stub):

```json
{
  "rendered_blocks": {
    "EMBED_CODE": {
      "title": "STRING",
      "block_type": "STRING",
      "html": "HTML",
      "error": null
    },
    "BAD_EMBED_CODE": {
      "title": null,
      "block_type": null,
      "html": null,
      "error": {
        "code": "ERROR_CODE",
        "message": "ERROR_MESSAGE"
      }
    }
  }
}
```

Mixed success/failure behaviour:

- HTTP status for mixed results: `200 OK`
- HTTP status for malformed request body: `400 Bad Request`

#### 8.4 Error envelope (shared)

Error payload (stub):

Note: current API endpoints commonly return a simple `{ "error": "..." }` string body for errors. The structure
below is the target shape for this ADR's expanded API.

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "ERROR_MESSAGE",
    "details": {
      "KEY": "VALUE"
    }
  }
}
```

## Out of scope

- **Write endpoints** (create/update a block via the API). ADR 13 raised this as a future possibility for the
  Whitehall migration; we're not designing it here. It has different authorisation, validation, and auditing
  requirements (the app already tracks edition history via domain events — [ADR
  9](./0009-use-domain-events-to-record-edition-history.md) — and any write path needs to go through the same
  workflow, not around it).
- **Editions** (`Edition`/`Block::Edition`) are not exposed through this API. The API is about blocks, not their
  underlying editions. The only edition-level data the API exposes is the `state` of the block (published vs draft),
  which is a property of the latest edition.
- **Host content / usage data** (`HostContentItem`, the data behind the "host editions" rollup shown in the block's
  show page) is fetched live from Publishing API today. Exposing it through this API would add a second dependency
  hop (caller → Content Block Manager → Publishing API) for data callers could get directly from Publishing API
  already. We're leaving this out unless a concrete consumer needs it.
- **Replacing Content Block Tools** as the rendering source of truth for Publishing API. ADR 13 named this as a
  longer-term possibility contingent on the API being reliable enough; this ADR is a step toward that but doesn't
  decide it.

## Consequences

### Positive

- The authoring widget gets the discovery, preview, and draft-state access it needs, which was the original
  motivation in ADR 13.
- A single batch render call replaces N sequential calls during republication, reducing load on both the caller and
  this app during exactly the event ADR 13 identified as highest-risk.
- Versioning from the start means the response shape (already partly settled by ADR 13's examples) can evolve
  without breaking existing callers.
- Routing the presenter through the `ContentBlock` facade keeps this API stable through the ADR 16 storage
  migration.
- Addressing everything by embed code (never `content_id`) keeps a single, consistent identifier across search,
  detail, and render, and lets the detail endpoint reuse the same format-resolution behaviour (`#FORMAT`) the render
  endpoint already has.

### Negative / trade-offs

- Authentication adds a second code path (public vs authenticated) to test and maintain, on top of the two Signon
  and JWT paths the fact-check view already has.
- Caching rendered HTML introduces invalidation complexity: a published edit must bust the cache for every embed
  code that resolves to that edition.
- As ADR 13 already accepted: if this API later becomes the rendering source of truth for Publishing API, Publishing
  API's availability becomes dependent on Content Block Manager's. This ADR doesn't change that trade-off, just
  moves us closer to it.
- Deprecating the current unversioned/single-render routes requires coordinating with whatever has already
  integrated against them (the widget, if it's live against the current API) before removal.

### Follow-up work

- Confirm deprecation timeline for the unversioned routes and single-embed-code render endpoint with any existing
  consumers before removing them.
- Bring the caching/rate-limiting proposal to the developer and technical architecture communities, per the
  commitment in ADR 13.
- Add Pact contract tests for consuming apps (Whitehall, the widget) once they integrate, as ADR 13 suggested.
- Assign owners and target dates for: deprecation communications, JWT token issuance/rotation design, and
  caching/rate-limit rollout.
