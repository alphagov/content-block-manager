# 7. Add Fact Check App as a Rails Engine

Date: 2025-11-18  
Status: Accepted

## Context

GOV.UK’s Content Block Manager requires a workflow for 2i and Fact Check processes, allowing subject matter experts to 
review proposed changes to content blocks before publication. These fact checkers often work outside the core GOV.UK 
organisation and therefore do not have access to GOV.UK Signon.

We need a simple and secure way to share proposed changes with fact checkers so they can quickly view and approve 
updates. The main application currently provides no mechanism for unauthenticated or externally authenticated access.

## Problem

Fact checkers need read-only access to proposed content block changes, but:

- they cannot use Signon,
- they must receive links that can be shared outside GOV.UK organisations,
- the main application should not expose these views directly, and
- any access mechanism must minimise the security risk to GOV.UK systems and data.

## Decision

We will implement a dedicated, lightweight "fact check" interface as a **Rails engine** within the Content Block Manager 
application.

The engine will:

- expose read-only views of proposed content block changes (and a comparison with previous versions),
- use authentication with an optional shareable preview link that bypasses authentication, following the 
[established pattern used on the draft stack][1],
- be isolated from the main application using [Packwerk][2] packages and the [Packwerk Privacy Checker][3] to strictly enforce 
dependency boundaries.

This approach creates a clear separation of concerns:

- the main application continues to use Signon-based authentication and maintain internal editing workflows,
- the fact check engine provides a limited, externally accessible surface with simplified authentication.

By implementing this as a Rails engine, we retain flexibility to extract it into a standalone application in the future 
with minimal refactoring.

## Alternatives Considered

1. **Adding controllers/views inside the main app**  
   Rejected because this would mix authentication models inside a single application context, increasing the risk of 
   privileged endpoints becoming inadvertently accessible.

2. **Creating a separate standalone application**  
   Rejected for now due to higher operational overhead (infrastructure, deployment, monitoring). A Rails engine gives 
   us separation while keeping operational complexity low.

## Security Considerations

Because the fact check engine uses looser authentication, we will:

- strictly limit the data the engine can access to only what is necessary for previewing proposed changes;
- enforce package boundaries with Packwerk, ensuring the engine only consumes explicitly public APIs;
- ensure preview links can be revoked or regenerated;
- log accesses for auditing and monitoring purposes;
- avoid providing any mutation or write operations within the engine.

We will also review whether rate limiting or other mitigations are required as usage patterns become clearer.

## Operational Considerations

- The engine will be mounted under a dedicated path (e.g. `/fact-check`) within the existing application deployment.
- It shares the same deploy pipeline, monitoring, and error reporting as the main app.
- Pages rendered by the engine will not rely on the user having cookies or Signon sessions.

## Consequences

- **Positive:**
    - Cleaner separation of concerns between internal and external workflows.
    - Reduced complexity in the main application’s authentication and routing logic.
    - A well-bounded component that can be extracted to a standalone service if required.

- **Negative / Risks:**
    - Additional responsibility to maintain Packwerk boundaries to avoid dependency creep.
    - Basic Authentication and shareable links must be monitored carefully to avoid accidental exposure.
    - Testing must ensure the engine does not inadvertently access or expose privileged data.

[1]: https://docs.publishing.service.gov.uk/manual/content-preview.html#authentication-and-authorisation
[2]: https://github.com/Shopify/packwerk
[3]: https://github.com/rubyatscale/packwerk-extensions?tab=readme-ov-file#privacy-checker
