# 14. Precompute API cache for resilience

Date: 2026-05-19

Status: Draft

## Context

[ADR 13: Add an API for Content Block Manager][] establishes that Content Block Manager (CBM) will expose a 
rendering API (`POST /api/blocks/render`) which Publishing API and other applications will call instead of rendering 
content blocks locally via the `content_block_tools` gem.

This will introduce a network dependency where none exists today. There are two republication scenarios that 
exercise this dependency differently:

### 1. Routine republishing: a new edition of a block

When an editor updates a content block, all documents embedding it are republished with freshly rendered HTML. 
Typically this affects 5-100 documents, currently containing 1-5 embed codes, though as Content Block Manager 
becomes more popular these counts will increase significantly. This republishing must complete promptly so editors see their changes propagate.

### 2. Rare bulk republishing: publishing app performs mass republishing

From time to time, a publishing app like Whitehall republishes a large category of its documents. Whitehall has approximately 500k documents of which ~400k are live. A category for republication might be "all publications" (~250k documents). See [Whitehall's republishing helper][whitehall-republishing].

In a few years, once content blocks are widely adopted, a mass republication might involve 100k documents with between 1 and 50 embed codes each — up to 5 million embed code resolutions in a single burst.

### The publish-render mechanism

Each republication triggers a `DownstreamLiveJob` in Publishing API, which calls `ContentEmbedPresenter` to render 
embedded content. Today this renders locally via the gem (sub-millisecond). Under the new architecture, each job 
will make a network call to CBM's render API.

### Objective

This ADR proposes a strategy to ensure the render API is:

1. performant under both routine and bulk republication, and is
2. resilient to transient failures

## Decision

### 1. Precompute rendered output on publish, with lazy fallback

When an edition is published, CBM will render all known embed code variants for that block and store the results in 
cache. The render API will resolve each embed code from cache. Cache misses will fall back to live rendering and 
will be cached for subsequent requests.

#### Cache granularity

The grain of the cache will be the individual embed code, rather than the entire HTTP request. A `POST 
/api/blocks/render` request will contain an arbitrary combination of embed codes (whichever appear in a particular 
document). Caching whole requests would result in many misses since most documents have will have a unique 
combination of embed codes. Caching per embed code means a rendered `{
{embed:content_block_pension:state-pension/rates/weekly-rate/amount}}` is stored once and reused across all 
documents that embed it. e.g.

```
Cache key: "render:#{embed_code}:#{edition_id}"
TTL: no expiry (invalidated explicitly on publish)
```

#### Cache invalidation

When a new edition is published, we will bust the cache for that block's embed codes and repopulate it via a 
precompute routine.

#### Rationale

CBM owns the schemas (including field paths and format metadata), so it knows all valid embed code variants at publish time. The number of unique embed codes remains small relative to the number of documents that reference them — this asymmetry will make caching effective.

### 2. Use Redis as the cache backing store

We will use `ActiveSupport::Cache::RedisCacheStore` via `Rails.cache`. Redis is already in use for Sidekiq, so this 
adds no new infrastructure. A shared cache will allow the precompute process to populate in a single place for all CBM processes/pods to benefit immediately.

### 3. Rely on Sidekiq retry for resilience (initially)

If the render API is unavailable or times out, `DownstreamLiveJob` in Publishing API will fail and retry via 
Sidekiq's built-in exponential backoff (25 retries over ~21 days). This provides resilience without application-level retry logic.

More sophisticated patterns (e.g. client retry, circuit breaker) are noted as future options if monitoring reveals frequent transient failures causing unacceptable republication delays. However, the complexity of implementing and tuning these strategies may not be required.

### 4. Strategy pattern for gem migration

We will retain the `ContentBlockTools::ContentBlock#render` interface, which applications (Publishing API, Whitehall,
Mainstream Publisher, Smart Answers) are using via the `content_block_tools` gem. We will use a "strategy" pattern to switch between:

- `LegacyRenderingStrategy` — current behaviour (local gem rendering)
- `ApiRenderingStrategy` — calls CBM's render API via `gds-api-adapters`

`ContentEmbedPresenter` in Publishing API will continue to call `ContentBlock#render` unchanged. The switch is a configuration change, not a code change in consuming apps.

#### Migration sequence

1. Deploy with `LegacyRenderingStrategy` (no change to current behaviour)
2. Switch to `ApiRenderingStrategy` via config/feature flag
3. Monitor: compare render output, latency, error rates
4. Once proven, remove `LegacyRenderingStrategy` and all rendering code from the gem (ViewComponents, FieldPresenters, etc)

### 5. Observability

We will include instrumentation on the rendering API to monitor:

- **Per-call latency**: P50, P95, P99 response times, distinguishing cache hits from cache misses
- **Cache hit rate**: ratio of cache hits to total lookups
- **Error rate**: 5xx responses, timeouts

These metrics should provide early warning of degradation and inform decisions:

- in the transition period: whether to switch from the `ApiRenderingStrategy` back to the `LegacyRenderingStrategy`
- once fully migrated: whether to investigate client-level retry or circuit breaker patterns

## Consequences
### Performance characteristics

With precomputed caching and Redis we expect to observe:

- **Cache hit (expected case):** Redis lookup + network round-trip ≈ 5-20ms
- **Cache miss (rare, lazy fallback):** DB query + component render + cache write ≈ 50-200ms

**Routine republishing** (5-100 documents after a block edit): will complete in seconds. Precompute will run at 
publish time, so all embed codes for the updated block will have been cached before republication begins. This should result in a near-100% cache hit rate.

**Bulk republishing** (100k documents, 1-50 embed codes each, 20 Sidekiq threads): the cache should be effective 
because the number of **unique** embed codes is small relative to the number of documents. However, bulk 
republishing is not triggered by a block being published, so the precompute process may not have run for every block 
referenced. Cache misses will be filled lazily and cached for subsequent requests. In the worst case (cold cache), the first request for each unique embed code will take 50-200ms. Subsequent requests will hit cache at 5-20ms.

### What stays in the gem vs moves to CBM

Once the API is proven and the legacy strategy is removed:

**Stays in the gem** (thin client):
- `ContentBlockReference` — embed code detection/parsing
- `EmbedCode`, `InternalContentPath`, `Format` — supporting parse classes
- `ApiRenderingStrategy` — HTTP client wrapping `gds-api-adapters`

**Moves to CBM**:
- `Renderer` and all rendering orchestration
- All ViewComponents (Contact, Pension, Tax, TimePeriod, etc.)
- All FieldPresenters
- Helpers (Govspeak, OverrideClasses)
- Engine and stylesheets

### Availability dependency

Content Block Manager will become a runtime dependency for publishing. This is accepted per [ADR 13: Add an API for Content Block Manager][]. This ADR describes these mitigations:

- Precomputed cache means the API will serve from Redis, rather than by doing expensive computation on each request
- Sidekiq retry will handle transient outages automatically
- A "strategy" pattern in the `content_block_tools` gem will allow us to swtich to local rendering during extended outages if needed

### Future considerations

- **Client-level retry** (1-2 immediate attempts) could be added if monitoring shows frequent transient timeouts 
  causing unnecessary Sidekiq retry delays

- **Circuit breaker** could be added if CBM experiences sustained outages that cause Sidekiq queue buildup in Publishing API

- **Cache warming on deploy**: after a CBM deploy that clears Redis, a background job could re-precompute all published blocks to avoid a burst of cache misses

- **Long-term volume growth**: as the number of documents using content blocks grows, Sidekiq concurrency and CBM scaling may need attention. The caching strategy should remain sound, assuming that unique embed codes grow slowly relative to document count.

## Related decisions

- [ADR 13: Add an API for Content Block Manager](0013-add-an-api-for-content-block-manager.md)

[whitehall-republishing]: https://github.com/alphagov/whitehall/blob/587206dbae505eb4fee4034164dbe62ab58ef6d8/app/helpers/admin/republishing_helper.rb

[ADR 13: Add an API for Content Block Manager]:
https://github.com/alphagov/content-block-manager/blob/9d9f52659f2c5724848795ae260ee827ce5cbdaa/docs/architecture/decisions/0013-add-an-api-for-content-block-manager.md