# 13: Add composite block type

Date: 2026-05-07

Status: Draft

## Context

### Driver

Editors need to control composed content (text interspersed with dynamic data 
from multiple content blocks) without developer involvement. Currently, when 
rendering requires data from multiple blocks (e.g. the pension one-off arrears 
paragraph which combines pension rates with a contact link), the composition 
would be hardcoded in developer-maintained "formats". (See [Tools PR 156][pension-pr])


### Rationale

1. **Editors control the copy** - text changes should not require developer 
   involvement. See [Content Block Editor][content-block-editor].
2. **Links and data are dynamic** - if a URL or rate changes, updating the 
   constituent block propagates automatically
3. **Auditable** - clear visibility of what references what, via the existing 
   dependency tracking infrastructure
4. **No nesting** - composite blocks cannot reference other composite blocks.  
   This constraint:
    - Keeps the dependency graph to a single level of indirection
    - Ensures the "impact of change" UI remains clear to editors
    - Makes cache invalidation tractable
    - Avoids circular reference challenges


## Decision

Add a new block type, `composite`, which allows editors to author blocks that 
combine free-form Govspeak text with embedded references to other content 
blocks.

### Illustrative example

A composite block `pension-one-off-arrears` laid out in `Edition#details`:

```ruby
{
  body: <<~GOVSPEAK
    If you defer your
    {{embed:content_block_contact:pension-office/contact_links/new_state_pension#new_state_pension_link}}
    for 52 weeks, you'll get a one-off arrears payment of
    {{embed:content_block_pension:new_state_pension#one_off_arrears_52_wks}}.

    If you defer your
    {{embed:content_block_contact:pension-office/contact_links/new_state_pension#new_state_pension_link}}
    for 27 weeks, you'll get a one-off arrears payment of
    {{embed:content_block_pension:new_state_pension#one_off_arrears_27_wks}}.
  GOVSPEAK
}
```

Embedded via: `{{embed:content_block_composite:pension-one-off-arrears}}`

## Consequences

### Two-level dependency tracking
When an editor changes a constituent block, the "impact of change" view (currently 
[`HostEditionsTableComponent`][host-editions-table]) must show:

    1. Documents directly embedding the changed block
    2. Composite blocks referencing the changed block
    3. Documents embedding those composite blocks

The existing Publishing API [dependency resolution and link expansion][link-expansion]  
mechanisms will need to support this two-level walk.

### Auto-update on publish
When a constituent block is published, composite blocks referencing it update 
automatically. No editor action is required on the composite itself.

### Schema and validation
A new `composite` schema definition is needed (see [existing schema definitions][schema-definitions]).  
Validation must enforce the no-nesting constraint (reject embed codes referencing 
other composite blocks).

### Authoring UI
A version of the authoring widget ([Content Block Editor][content-block-editor] ) 
will be used within the Content Block Manager to let editors compose blocks. 


### Out of scope

### Authoring UI design
The visual editor for composing blocks (including the block picker, live preview, 
and how the authoring widget from ADR 0012 is adapted for use within the Content 
Block Manager itself) is an implementation concern to be designed separately.

### Detailed rendering pipeline specification
The exact sequence of embed code resolution, Govspeak processing, and HTML wrapping 
within the rendering API. This includes questions about how format specifiers 
interact with Govspeak context (e.g. `#new_state_pension_link` rendering a local 
`<a>` tag vs the default absolute URL).

### Caching strategy for composite rendered output
Composite blocks depend on multiple constituent blocks, making cache invalidation 
more complex than for simple blocks. The approach to caching (keyed by constituent 
edition versions, TTL-based, or uncached) will be determined as part of the implementation.

## References

- [Content Block Editor][content-block-editor] - an authoring widget to allow editors
  to discover and embed content blocks
- [Publishing API: link expansion][link-expansion] - how links between  
  content items are stored, expanded, and resolved
- [Pension one-off arrears PR][pension-pr] - the PR which motivated the composite blocks concept

[content-block-editor]: https://github.com/alphagov/content-block-editor
[link-expansion]: https://github.com/alphagov/publishing-api/blob/main/docs/link-expansion.md
[pension-pr]: https://github.com/alphagov/govuk_content_block_tools/pull/156
[host-editions-table]: https://github.com/alphagov/content-block-manager/blob/main/app/public/components/shared/host_editions_table_component.rb
[schema-definitions]: https://github.com/alphagov/content-block-manager/tree/main/app/models/schema/definitions