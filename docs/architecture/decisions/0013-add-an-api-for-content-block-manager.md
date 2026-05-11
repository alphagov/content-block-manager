# 13. Add an API for Content Block Manager

Date: 2026-05-11

Status: Accepted

## Context

We need to make it easy for editors to use content blocks. The [**authoring widget**](https://github.com/alphagov/content-block-editor) 
is an important piece of that strategy. The widget will be used by publishing apps to allow editors to:

- preview a rendered block when faced with an embed code in their document
- discover available blocks, preview them, and select one to have its embed code inserted into their document (e.g. 
via an "Insert content block..." call to action)

The widget needs both discovery/search and rendering to be effective. The Content Store cannot provide either 
adequately.

An API may also be useful for migrating data from other apps to the Content Block Manager, such as the planned work on 
migrating contacts from Whitehall.

## Decision

We will add an API to Content Block Manager. This will use the same engine-based pattern as we already use for 
previewing content blocks.

Why we need our own API rather than relying on the Content Store:

### 1. The widget needs discovery/search

Content Store has no facility for searching or browsing content blocks by type, organisation, or text content.

### 2. We will eventually need auth controls via Signon

This is true especially for draft content blocks, which the Content Store doesn't serve at all. Authorisation will 
restrict access based on content state and user permissions.

### 3. Multiple apps currently render blocks differently, fetching from different sources

Publishing API uses its own DB, Whitehall fetches from the Publishing API, Publisher and Smart Answers fetch from the 
Content Store, and the Content Block Manager uses its local DB. A single API consolidates this fragmentation.

### 4. Content Store isn't designed to serve building-block data

Content store is a read-only cache of published content designed to serve JSON representations of finished pages, not 
reusable components or rendered HTML fragments.

## Consequences

### Authentication

Initially, we will not worry about authentication, as we intend to only surface published blocks, which are in the 
public domain. However, if we want to surface draft blocks in the future, we may have to consider adding authentication, 
either via an API key or OAuth authentication.

If we went with API-key-based authentication, we would have to consider how we would authenticate via the client side 
(using Content Block Editor), as we would not want to surface the API key in the frontend code.

If we went with OAuth authentication, this would potentially give us greater control over what access a user has to 
which blocks, although this would make authentication more difficult, especially when using the app cross-platform.

### Replacing Content Block Tools

In future, we may want to consider replacing [Content Block Tools](https://github.com/alphagov/govuk_content_block_tools) 
as the source of truth with the API, which will allow non-Ruby applications to render content blocks.

## Availability dependency

If we decide to replace Content Block Tools with the API, the Publishing API (and other consumers) will depend on the 
Content Block Manager being available. This is accepted as a trade-off for eliminating rendering duplication and 
fragmentation.

### Volume and performance

Publishing apps commonly republish all their documents at once (mass republication). The API design must cope with 
high request volumes during these events. Considerations include:

- Batch vs individual embed code rendering (POST with JSON body allows batch; GET with query params is more RESTful 
but has URL length limits for long embed codes)
- Caching rendered output (keyed by embed code and edition version)
- Rate limiting or queuing strategies

We will propose a technical plan for caching and resilience to the GOV.UK developer and technical architecture 
communities to get early agreement on a robust strategy.

### Implementation

To make documentation and interoperability easier, we should consider using OpenAPI (Swagger) to define the API. We 
should look into tools we can use in Rails to make ensure the API is consistent and up-to-date with the specification,
such as [Rswag](https://github.com/rswag/rswag).

We should also consider using [Pact contract tests](https://docs.publishing.service.gov.uk/manual/pact-testing.html)
within any client apps that consume the API.

## Suggested endpoints

### `GET /api/blocks/search`

This endpoint will be used by our authoring widget to retrieve a list of blocks matching certain criteria. For example, 
an editor wants to "Insert a block" by perusing a list of all available blocks.

If no filtering criteria are supplied, the endpoint returns all available blocks. We expect that widget will have 
a need of properties including:

* organisation
* state (draft / published)
* block type
* block title
* embed code
* available embed codes

#### Parameters

* `block_type` (optional)
    * The block type to return
* `lead_organisation` (optional)
    * The lead organisation to filter by
* `keyword` (optional)
    * Any keyword(s) to filter by
* `state` (optional)
    * State to filter by (defaults to `published`)

#### Example response

```
{
  "status": 200,
  "body": {
    "total": 1,
    "pages": 1,
    "current_page": 1,
    "links": [
      {
        "href": "https://example.org/v2/content?document_type=taxon&fields%5B%5D=content_id&fields%5B%5D=locale&page=1",
        "rel": "self"
      }
    ],
  },
  "results": [
    {
      "title": "Some content block",
      "block_type": "pension",
      "url": "api/content-blocks/bed722e6-db68-43e5-9079-063f623335a7",
      "content_id": "bed722e6-db68-43e5-9079-063f623335a7",
      "organisation": {
        "name": "Some organisation",
        "content_id": "some-organisation-content-id"
      },
      "state": "published",
      "embed_code": "{{embed:content_block_pension:some-content-block}}"
      "formats" [
        "one_off_arrears_27_wks",
        "one_off_arrears_52_wks"
      ]
    }
  ]
}
```

### `POST /api/blocks/render`

This endpoint will be used by publishing apps which need to replace multiple embed codes with the corresponding content 
blocks' HTML, e.g. when publishing a document (Publishing API) or when rendering a local editor preview (Whitehall)

#### JSON attributes

* `embed_codes` (required)
    * An array of embed codes to render

#### Example response

```json
{
  "rendered_blocks": {
    "{{embed:content_block_pension:state-pension#one_off_arrears}}": {
      "title": "State Pension",
      "block_type": "Pension",
      "html": "<div class=\"content-block content-block--pension\" ...>...</div>"
    },
    "{{embed:content_block_time_period:tax-year#years_short}}": {
      "title": "Tax year",
      "block_type": "Time period",
      "html": "<span class=\"content-block content-block--time_period\" ...>2025-26</span>"
    }
  }
}
```
