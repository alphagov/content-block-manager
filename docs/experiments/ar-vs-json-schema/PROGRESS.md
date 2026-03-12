# Experiment Progress: ActiveRecord vs JSON Schema

**Experiment ID:** ADR-0011  
**Branch:** `exp/use-ar-rather-than-json-schema`  
**Started:** 2026-03-11  
**Status:** In Progress - Phase 4 Complete

## Overview

Exploring an alternative architecture for GOV.UK Content Block Manager. Instead of the current schema-driven generic approach (where all block types use JSON schemas and a generic `details` JSON column), we're testing traditional Rails ActiveRecord models with dedicated tables for each block type.

**Focus:** TimePeriod block type as proof-of-concept

## Architectural Decisions

### Core Design Choices

1. **Namespace:** All new code in `Block::` namespace (runs parallel with existing system)
2. **No Document STI:** `Block::Document` is a single concrete class
   - Has `block_type` column to track which edition type it uses ("time_period", "tax", etc.)
3. **Edition uses STI:** `Block::Edition` → `Block::TimePeriodEdition`, `Block::TaxEdition`, etc.
   - `block_editions` table has `type` column for Single Table Inheritance
   - **Important:** Removed `self.abstract_class = true` from Edition so STI works
4. **Content in specialized tables:** Each edition type has its own content tables
   - Example: `Block::TimePeriodEdition` has_one `Block::TimePeriodDateRange`
   - Content tables: `block_time_period_date_ranges`
5. **No details JSON column:** Each edition subclass implements `#details` method that serializes from its associated content models
6. **Description field:** All blocks have `description`, stored on `block_editions.description`
7. **One-way serialization:** Only need `#to_details` (not `.from_details`) - content authoring app
8. **Type-specific associations:** Each block type gets its own `has_many` association on Document
   - e.g., `has_many :time_period_editions` scoped by STI type
   - Makes relationships explicit, enables cleaner controller code

## Key Discoveries

### STI Requires No `abstract_class`

Initially set `self.abstract_class = true` on `Block::Edition` which disabled STI behavior and caused `type` column to not be set automatically. Removed this line to fix.

### `inverse_of` Critical for Nested Attributes

When building unsaved nested objects (document → edition → date_range), Rails needs `inverse_of` on associations to populate the association cache bidirectionally. Without it:

- `date_range.edition` queries the database (finds nothing since id is nil) → validation fails
- With `inverse_of`: Rails returns the in-memory object → validation passes
- The magic happens in `association.rb:224` (`set_inverse_instance`)

### Type-Specific Associations Improve DX

Instead of `@document.editions.build(type: "Block::TimePeriodEdition")`, using explicit associations like `@document.time_period_editions.build` is cleaner and aligns with the experiment's goal of making each block type a first-class entity.

## Development Conventions

### Testing Standards

- No `require "rails_helper"` in specs (file doesn't exist)
- Model specs: `spec/unit/app/models/block/`
- Controller specs: request specs in `spec/requests/block/`
- Routing specs: `spec/routing/block/`
- Use `build` instead of `create` when DB persistence not needed (keeps tests fast)
- Factory names: shortened (`:time_period_edition` not `:block_time_period_edition`, but `:block_document` to avoid collision)

### Commit Workflow

1. Agent stages files for commit using `git add`
2. User reviews staged changes (`git diff --staged`)
3. User tests manually (run specs, try in console, etc.)
4. User makes any adjustments and restages if needed
5. User commits manually with their own commit message
6. Agent provides suggested commit message (title + body format)

**Key principle:** Work in small, atomic commits. Each commit should be self-contained with passing tests. When staging changes, always consider whether formatting or fixes belong in the current commit or should be rebased into earlier commits to maintain atomicity.

## Progress Log

### Phase 0: Cucumber Features ✅

- **2026-03-11** - Created features in `features/block/time_period/` with `@wip` tags
- Step definitions deleted due to ambiguous step errors (to address later)
- Features will drive development but aren't running yet

### Phase 1: Foundation - Database & Models ✅

**Migrations:**

- Created `block_documents` table
- Created `block_editions` table with STI support
- Created `block_time_period_date_ranges` table

**Models:**

- Implemented `Block::Document` model with tests and factory
- Implemented `Block::Edition` base model (fixed STI issue by removing `abstract_class`)
- Implemented `Block::TimePeriodEdition` minimal model
- Implemented `Block::TimePeriodDateRange` model
- Added date_range association and `#details` serialization to TimePeriodEdition
- Added `inverse_of` to all associations for nested attributes support

**Tests:** 32 model specs passing

### Phase 2 & 3: Routes, Controllers, Views ✅

**Routing:**

- Added routes for Block::TimePeriod CRUD
- Created routing specs (10 examples passing)
- Skeleton controller

**Controller & Views:**

- Implemented `Block::TimePeriodsController` with full CRUD (new, create, show, edit, update)
- Placeholder views for new, edit, show
- Request specs for all controller actions (21 examples passing)
- GDS-SSO authentication setup in specs

**Tests:** 31 total specs passing (21 request + 10 routing)

### Phase 4: Refining the API ✅

**2026-03-12 Morning** - Added type-specific associations to Document:

- Added `has_many :time_period_editions` scoped by STI type
- Simplified controller to use explicit associations
  (`time_period_editions.build`)
- Created `Block::OtherEdition` stub for testing STI scoping
- Improved test coverage for association filtering

**Tests:** 39 total specs passing (21 request + 10 routing + 8 document model)

### Phase 5: GOV.UK Forms Implementation 🔄 (In Progress)

**2026-03-12 Afternoon** - Implementing proper GOV.UK Design System forms:

**Completed:**

- Replaced non-existent `title` component with proper `heading` component
  - Uses `heading_level: 1` and `font_size: "xl"` for page titles
- Implemented datetime inputs using Rails multiparameter attributes:
  - Date fields: day/month/year using `date_input` component
  - Time fields: hour/minute using `select_hour`/`select_minute` helpers
  - Convention: `field_name(1i)` through `field_name(5i)` for year, month,
    day, hour, minute
  - Separate fieldsets for START and END datetime values
- Created comprehensive `_form.html.erb` partial (245 lines):
  - Character count component for title (255 char limit)
  - Textarea component for description
  - Complex nested datetime inputs for date range
  - Proper GOV.UK component integration throughout
- Updated all three views (new, edit, show) with proper layouts:
  - Page headings, back links, grid layouts
  - Summary list on show page
  - Consistent GOV.UK styling
- Modified controller to handle datetime multiparameter attributes

**Current Status:**

- View rendering: ✅ PASSING (verified for new action)
- Full test suite: ⚠️ NOT VERIFIED (likely failing due to parameter
  structure mismatch)
- Main issue: Tests expect `block_time_period_edition` params but form
  submits `edition` params

**Discoveries:**

- GOV.UK components use `heading` not `title`
- Existing app has reusable datetime patterns in
  `app/components/edition/details/fields/date_time_component.html.erb`
- Component guide at https://components.publishing.service.gov.uk/
  component-guide is essential reference
- `select_hour` and `select_minute` need careful parameter structure
  with `prefix` and `field_name` options

**Next Tasks:**

- [ ] Decide: Update tests to match form OR update form to match tests
- [ ] Get all 21 request specs passing
- [ ] Consider extracting datetime fields into reusable partial
      (lots of duplication)
- [ ] Replace inline styles with proper CSS classes
- [ ] Test forms manually in browser

## Current State

**Working directory:** `/Users/ed/govuk/govuk-content-block-manager`  
**Branch:** `exp/use-ar-rather-than-json-schema`  
**Last commit:** Add type-specific edition associations (forms WIP unstaged)
**Tests status:**

- Phase 1-4 tests: ✅ 39 specs passing
- Phase 5 tests: ⚠️ Unknown (forms in WIP state)

### Files Modified/Created (Phase 5 - Staged)

- `app/controllers/block/time_periods_controller.rb` - Updated for
  datetime params, form structure
- `app/views/block/time_periods/_form.html.erb` - NEW: Comprehensive
  GOV.UK form (245 lines)
- `app/views/block/time_periods/new.html.erb` - Proper heading, layout
- `app/views/block/time_periods/edit.html.erb` - Proper heading, layout
- `app/views/block/time_periods/show.html.erb` - Summary list, proper
  display

## Next Steps

### Immediate (Phase 5 Completion)

1. **Fix parameter structure** - Align form params with test expectations
   or update tests
2. **Get all specs passing** - Verify full test suite (21 request +
   10 routing + 8 model specs)
3. **Test in browser** - Manual testing via Rails server
4. **Refactor datetime fields** - Consider extracting into reusable
   partial/component
5. **Replace inline styles** - Use proper CSS classes for datetime layout

### Future Phases

1. **Add second block type** - Implement Tax block to validate pattern
   scales
2. **Run cucumber features** - See what passes with @wip tags
3. **Add validation** - Business logic for date ranges, required fields
4. **Add index action** - List all time periods
5. **Add workflow/state machine** - Complexity deferred from Phase 1
6. **Performance evaluation** - Compare with JSON schema approach
7. **Developer experience assessment** - Document learnings

## References

- **ADR:** `docs/architecture/decisions/0011-experiment-with-traditional-activerecord-models.md`
- **Cucumber features:** `features/block/time_period/*.feature`
- **Models:** `app/models/block/`
- **Specs:** `spec/unit/app/models/block/`, `spec/requests/block/`, `spec/routing/block/`
- **Factories:** `spec/factories/block/`
