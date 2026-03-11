# 11. Experiment with Traditional ActiveRecord Models for Content Blocks

Date: 2026-03-11

Status: Experimental

## Context

### Current State

The Content Block Manager currently uses a **schema-driven generic approach** for modeling content blocks:

1. **Single Document Model:** All block types use a single `Document` model (no subclasses).
2. **Single Edition Model:** All block types use a single `Edition` model with a generic `details` JSON column.
3. **JSON Schema Validation:** Block type structure is defined and validated via JSON schemas stored in `app/models/schema/definitions/*.json`.
4. **Generic Forms:** Form interfaces are dynamically generated from the JSON schemas.

This architecture provides flexibility and allows new block types to be added by defining a JSON schema without creating new models or migrations.

This was a necessary technical design initially as all schemas were defined in Publishing API. However, in order to have greater control, particularly over validation, we've recently moved the schema into this repository (See [ADR 10 Make Content Block Manager the source of truth for schemas][])

The use of JSON schema definition is no longer a requirement.

### The Question

As the application grows, we're evaluating whether the schema-driven approach provides the best developer experience and maintainability, or whether a **traditional Rails ActiveRecord approach** with dedicated models and tables might be clearer and easier to work with.

Specifically, we want to understand:

2. **Developer Experience:** Is it easier and faster to work with explicit Rails models and associations vs. generic JSON columns? Our experience when adding a new block type is that there are numerous differences or additional features which are needed. At face value they appear minor but in reality prove complex to introduce to an application model which is entirely generic. Our small number of classes can do everything, but at what price in terms of complexity and cognitive load.
3. **Maintainability:** Are dedicated models with typed columns easier to understand and modify than schema definitions?
4. **Adding Fields:** Is it simpler to add a migration for a new column vs. updating a JSON schema?
5. **Performance:** Do typed columns with proper indexes perform better than querying within JSON?
6. **Testing:** Are traditional model tests more straightforward than testing schema validation?

## Decision

We will conduct an **experiment** by implementing an alternative architecture using traditional ActiveRecord models, running **in parallel** with the existing schema-driven system.

### Experiment Scope

We will implement the **TimePeriod** block type as a proof-of-concept using the new architecture. This will allow us to:

- Compare both approaches side-by-side in the same codebase
- Evaluate real-world developer experience
- Make an informed decision about which direction to pursue

This is **not yet** a decision to migrate away from the existing schema-based paradigm - it is purely exploratory.

## Architecture

### Namespace

All experimental code will live in the `Block::` namespace to run parallel with the existing system:

- Existing: `Document`, `Edition`
- Experimental: `Block::Document`, `Block::Edition`, `Block::TimePeriodEdition`, etc.

### Key Architectural Choices

#### 1. Document Model (No STI)

`Block::Document` is a **single concrete class** (no Single Table Inheritance):

- Has a `block_type` string column to track which edition type it uses ("time_period", "tax", etc.)
- Does not subclass (no `Block::TimePeriodDocument`, etc.)
- Rationale: Documents are generic containers; the specificity lives in editions

#### 2. Edition Model (STI)

`Block::Edition` uses **Single Table Inheritance**:

- Base class: `Block::Edition` (abstract - cannot instantiate directly)
- Subclasses: `Block::TimePeriodEdition`, `Block::TaxEdition`, etc.
- `block_editions.type` column stores the subclass name
- Rationale: Different block types have different fields and behavior

#### 3. Content in Specialized Tables

Each edition type has its own dedicated content tables with typed columns:

- Example: `Block::TimePeriodEdition` has_one `Block::TimePeriodDateRange`
- Content table: `block_time_period_date_ranges` with `start` and `end` datetime columns
- Rationale: Explicit schema, database-level validation, proper indexing

#### 4. No Generic Details Column

Instead of a `details` JSON column:

- Each edition subclass implements a `#details` method that serializes from its associated content models
- Example: `TimePeriodEdition#details` composes from `description` + `date_range.to_details`
- Rationale: One-way serialization for API consumption; editing happens via associations


#### 6. Two-Controller Pattern for Multi-Step Forms

Rather than use general-purpose multi-step "wizard" code (`Workflow`), it may be preferable, especially in the case of simple blocks (e.g. `TimePeriod`) to use separate controllers for different form steps:

- `TimePeriodEditionsController` - Step 1: common fields (title, description, organisation)
- `TimePeriodDateRangesController` - Step 2: type-specific fields (start/end dates)

#### 7. Reuse of Existing Concerns

Where possible, this experiment will aim to reuse existing behaviour which is packaged up in modules, e.g.:

- `Block::Edition` includes `::Edition::HasLeadOrganisation` for organisation validation
- `Block::TimePeriodDateRange` includes `DateValidation` for handling invalid multiparameter dates

#### 8. Shared Fields on Base Table

Fields common to all block types live on `block_editions`:

- `description` - all block types have this
- `title` - all block types have this
- `instructions_to_publishers` - all block types have this
- Rationale: Avoids duplication in type-specific tables

## Implementation Notes

### Complexities to explore

#### Date multiparameter assignment

It will be interesting to explore whether validation of a `TimePeriod#date_range`'s `start` and `end` is significantly simpler using this active record approach.

Rails date fields submit as multiparameter attributes (e.g., `start(1i)`, `start(2i)` etc). Perhaps use of the existing `DateValidation` behaviour will do whats's needed?

## Implementation Plan

### Database Schema

```
block_documents
  - id
  - content_id (uuid, unique, indexed)
  - sluggable_string (unique, indexed)
  - content_id_alias (unique, indexed) -- generated via FriendlyId from sluggable_string
  - block_type (string: "time_period", "tax", etc.)
  - embed_code -- uses content_id_alias, e.g., {{embed:content_block_time_period:current-tax-year}}
  - deleted_at
  - timestamps

block_editions (STI)
  - id
  - block_document_id (FK to block_documents)
  - type (STI discriminator)
  - title
  - description
  - instructions_to_publishers
  - lead_organisation_id (uuid) -- FK to organisations
  - timestamps

block_time_period_date_ranges
  - id
  - edition_id (FK to block_editions, unique index)
  - start (datetime)
  - end (datetime)
  - timestamps
```

### Model Structure

```ruby
Block::Document
  extend FriendlyId
  friendly_id :sluggable_string, use: :slugged, slug_column: :content_id_alias

  has_many :editions, class_name: "Block::Edition"

  def built_embed_code
    "{{embed:content_block_#{block_type}:#{content_id_alias}}}"
  end

Block::Edition (abstract STI base)
  include ::Edition::HasLeadOrganisation  # reuses existing concern

  belongs_to :document, class_name: "Block::Document"

  def details
    raise NotImplementedError
  end

Block::TimePeriodEdition < Block::Edition
  has_one :date_range, class_name: "Block::TimePeriodDateRange"

  def details
    {
      "description" => description,
      "date_range" => date_range.to_details
    }
  end

Block::TimePeriodDateRange
  include DateValidation  # reuses existing concern for invalid date handling

  belongs_to :edition, class_name: "Block::TimePeriodEdition"

  def to_details
    {
      "start" => { "date" => ..., "time" => ... },
      "end" => { "date" => ..., "time" => ... }
    }
  end
```

### Controller Structure (Two-Controller Pattern)

```ruby
Block::TimePeriodEditionsController
  # Step 1: Common fields (title, description, organisation)
  def create
    @edition = Block::TimePeriodEdition.new(edition_params)
    @edition.build_document(block_type: "time_period")

    if @edition.save
      redirect_to edit_block_document_time_period_date_range_path(...)
    else
      render :new
    end
  end

Block::TimePeriodDateRangesController
  # Step 2: Type-specific fields (start/end dates)
  def update
    if @edition.update(edition_params)
      redirect_to block_time_period_edition_path(@edition)
    else
      render :edit
    end
  end
```

## Consequences

### Benefits of the Experimental Approach

We believe that this approach may be significantly easier (faster) to develop:

- fixing bugs
- adding features
- adding new block types

Once the service goes into maintenance mode, simplicity will be a major factor in its long term success. If it's hard to maintain and develop, it's likely to be perceived as risky and expensive.

### Drawbacks of the Experimental Approach

1. **More Code:** Requires models, migrations, and factories for each block type
2. **Schema Changes:** Adding fields requires migrations instead of JSON updates
3. **Less Flexibility:** Structure is more rigid (though this might be a good thing)
4. **Parallel Maintenance:** During the experiment, we maintain two systems

### Evaluation Criteria

After implementing the TimePeriod block with the new architecture, we will evaluate:

1. **Code Clarity:** Is it easier to understand what fields exist and how they relate?
2. **Development Speed:** How quickly can we add new fields or modify existing ones?
3. **Testing Experience:** Are tests easier to write and more reliable?
4. **Team Preference:** Which approach do developers prefer working with?

## Status

This ADR has **Experimental** status and will be updated to **Accepted** or **Rejected** after the experiment concludes.

[ADR 10 Make Content Block Manager the source of truth for schemas]: ./0010-make-content-block-manager-the-source-of-truth-for-schemas.md
