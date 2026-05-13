# 12. Offer alternate presentations of content blocks with formats

Date: 2026-05-07

Status: Accepted

## Context

### Driver

Editors need to embed the same content block data in different contexts,
each requiring a different presentation. For example, a tax year time period
might appear as "6 April 2025 to 5 April 2026" in body text but "2025-26" in
another place. Without a mechanism for this, editors must either accept a single
fixed rendering or resort to embedding individual fields and assembling them
manually in markdown -- something no editor will realistically do. This technique
of re-composing a representation from constituent attributes hits its limit when
the value needed exists within an attribute. For example, if I want the month
"April" from a datetime value of `2027-04-05T23:59:00+01:00`.

The problem is acute with structured blocks like tax rates. An income tax
table requires four rates, each with a band name, thresholds, and a percentage.
Presenting this as a table using individual field embeds would require the
editor to arrange twelve or more embed codes into a markdown table:

```
| Band                                        | Taxable income          | Tax rate    |
| ------------------------------------------- | ----------------------- | ----------- |
| {{embed:content_block_tax:income-tax/...}}  | Up to {{embed:...}}     | {{embed:…}} |
| {{embed:content_block_tax:income-tax/...}}  | {{embed:…}} to {{…}}    | {{embed:…}} |
| {{embed:content_block_tax:income-tax/...}}  | {{embed:…}} to {{…}}    | {{embed:…}} |
| {{embed:content_block_tax:income-tax/...}}  | over {{embed:…}}        | {{embed:…}} |
```

This is impractical. Formats solve both problems -- presentation variants of a
single value, and structured layouts over multiple values -- with the same
mechanism.

### Rationale

1. **Single embed code per use** - An editor should never need to scatter
   multiple embed codes across a markdown structure to represent one logical
   thing. A format lets a single embed code produce a complete rendered
   artefact (a formatted value, a table, a paragraph).

2. **Presentation logic belongs with the block type, not the document** -
   How a tax table is laid out, or how a date range is abbreviated, is
   determined by the block type's schema and rendering components. Pushing
   this into the embedding document (via manual markdown) scatters
   presentation logic into every document that uses the block.

3. **Formats are declared in schemas** - Each block type's JSON schema lists
   its supported formats via the `x-formats` extension (e.g.
   `["income_tax_table"]` for tax, `["years_short", "start_month_as_word", ...]`
   for time periods). This makes formats discoverable and validatable at
   edition creation time rather than failing silently at render time.

4. **Fail-fast validation** - Components validate the format specifier at
   initialisation against a `SUPPORTED_FORMATS` whitelist. An unrecognised
   format raises `InvalidFormatError` immediately, preventing silent rendering
   failures. This will prevent Publishing API's `Presenters::ContentEmbedPresenter`
   from publishing documents containing invalid formats.

## Decision

We will extend the embed code syntax with a **format specifier**, appended
after a `#` delimiter:

```
{{embed:content_block_time_period:tax-year#years_short}}
{{embed:content_block_tax:income-tax#income_tax_table}}
```

When no format specifier is present, the block renders in its default format.

Each block type declares its supported formats in two places:

1. **Schema metadata** - the `x-formats` field in the block type's JSON schema
   definition, making formats discoverable by the authoring UI
2. **Component code** - a `SUPPORTED_FORMATS` constant on the rendering
   component, enforced at initialisation

Rendering components follow a **dispatcher pattern**: the top-level component
for a block type (e.g. `TaxComponent`, `TimePeriodComponent`) validates the
format, then delegates to a format-specific sub-component (e.g.
`Tax::IncomeTaxTableComponent`, `TimePeriod::YearsShortComponent`). Each
sub-component has its own template and is independently testable.

### Illustrative examples

#### Value formatting ([time period][time-period-pr])

| Embed code                                                         | Output                       |
|--------------------------------------------------------------------|------------------------------|
| `{{embed:content_block_time_period:tax-year}}`                     | 6 April 2025 to 5 April 2026 |
| `{{embed:content_block_time_period:tax-year#years_short}}`         | 2025-26                      |
| `{{embed:content_block_time_period:tax-year#start_month_as_word}}` | April                        |

#### Structured layout ([tax rates][tax-table-pr])

`{{embed:content_block_tax:income-tax#income_tax_table}}` renders a complete
GOV.UK-styled HTML table:

| Band               | Taxable income      | Tax rate |
|--------------------|---------------------|----------|
| Personal Allowance | Up to £12,570       | 0%       |
| Basic rate         | £12,571 to £50,270  | 20%      |
| Higher rate        | £50,271 to £125,140 | 40%      |
| Additional rate    | over £125,140       | 45%      |

#### Calculated values ([pension arrears][pension-arrears-pr])

Given a Pension object with a weekly rate of £241.30, we can define 2 formats to 
provide calculated values for 27 and 52 week pension arrears calculations:

- `{{embed:content_block_pension:state-pension#one_off_arrears_27_wks}}` 
   renders £6,515.10 

- `{{embed:content_block_pension:state-pension#one_off_arrears_52_wks}}`
   renders £12,547.60

## Consequences

### Embed code syntax is extended
The `#` delimiter and format name are added to the embed code regex (`FORMAT_REGEX`). 
The `#` was chosen over alternatives (e.g. `|`) because it is URL-like and visually 
unambiguous. Existing embed codes without `#` continue to work unchanged, receiving 
the default format.

### Each format is a ViewComponent
Format sub-components live under the block type's namespace (e.g. 
`TimePeriod::YearsShortComponent`). This gives each format its own template and 
test suite, and allows formats to range from simple value transformations to 
complex structured layouts.

### Schema and code must stay in sync
`x-formats` in the JSON schema and `SUPPORTED_FORMATS` in the component must list 
the same formats. There is currently no automated check enforcing this; a discrepancy 
could cause the authoring UI to offer a format that fails at render time, or vice 
versa.

### New formats require code changes
Adding a format to a block type requires a new sub-component class, template, and 
tests, plus updating both the schema and the component's `SUPPORTED_FORMATS`. 
This is deliberate: formats encode presentation logic that should be reviewed and 
tested, not user-defined at runtime.

### Authoring UI can offer format selection
Because formats are declared in schemas, the planned authoring widget can present 
a list of available formats when an editor inserts a content block, constructing 
the correct embed code with the chosen format specifier.

### Out of scope

- **User-defined formats or templates** - formats are code-defined, not
  editable by content designers at runtime
- **Format composition** - combining multiple formats in a single embed code.
  The use of "composite blocks" will be presented in a future decision.
- **Format-specific preview in the Content Block Manager** - the CBM preview
  currently shows blocks in their default format; per-format preview is being
  explored in [PR #620][format-preview-pr]

## References

- [Time period format specifier PR][time-period-pr] - adds the `#` format
  syntax and six time period format variants
- [Income tax table format PR][tax-table-pr] - adds the `income_tax_table`
  format, rendering structured data as an HTML table from a single embed code
- [Pension arrears format PR][pension-arrears-pr] - an experimental PR exploring the
  use of a format to render an "example" containing 2 calculated values
- [Format-specific preview PR][format-preview-pr] - draft work on per-format
  preview in the Content Block Manager

[time-period-pr]: https://github.com/alphagov/govuk_content_block_tools/pull/147
[tax-table-pr]: https://github.com/alphagov/govuk_content_block_tools/pull/155
[pension-arrears-pr]: https://github.com/alphagov/govuk_content_block_tools/pull/156
[format-preview-pr]: https://github.com/alphagov/content-block-manager/pull/620
