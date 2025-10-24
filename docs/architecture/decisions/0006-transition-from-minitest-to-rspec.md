# 6. Transition from Minitest to RSpec

Date: 2025-10-23

## Context

This application was originally created inside the [Whitehall][whitehall] application, which uses [Minitest][minitest] as its
testing framework. The guidance from the [Govuk Developer Docs][dev-docs] is as follows:

> The preferred framework for testing Rails applications is rspec-rails where we aim to adhere to the project's
> conventions. rubocop-govuk provides a linting configuration for RSpec. For mocking and test doubles you should use the
> provided rspec-mocks framework.

It was also noted in a previous ADR [# 3. Move out to new Application][converting] that we should look into converting tests
off Minitest. As such, we need a plan for updating more than 100 test files from Minitest to RSpec.

### Option 1
- New files to use RSpec going forwards.
- When a developer touches a test file using Minitest they convert it to RSpec first then add their tests.

#### Pros
- No upfront time cost to convert all the files.
- Tests get converted as and when people are working in those areas, so potentially working on areas that are more actively
  developed first.
- We could do this for a while and then later decide to do a bulk conversion of any remaining files to make sure everything is
  consistent (or not, if we don't care about the remaining files).

#### Cons
- Some files may never get converted if they are not touched again. (but maybe that's okay?)
- Inconsistent test styles across the codebase for a while.
- More cognitive load on developers to remember to convert tests when working in old files.

### Option 2
- We make tasks in the backlog to convert Minitest files to RSpec and prioritise a few alongside each sprint.

#### Pros
- Spreads the time cost of conversion over multiple sprints.
- We convert files as and when people are working in those areas. This means potentially working on areas that are more actively
  developed first.

#### Cons
- Tasks may not get prioritised by the team so conversion may take a long time.
- Some files may never get converted if they are not touched again. (but maybe that's okay?)
- Potentially inconsistent test styles across the codebase for a while.

## Rejected Options

### Option 3
- We take the time out of sprint work to convert all the 100 files up-front now.

### Pros
- Consistent test style across the codebase from the start.
- No cognitive load on developers to remember to convert tests when working in old files.

### Cons
- Significant upfront time cost to convert all the files.
- Time spent on converting files ahead of feature work may delay other priorities. The team are unlikely to accept this level of
  delay in feature delivery.

### Option 4
- Keep Minitest as the testing framework for this application.

#### Pros
- No time cost to convert files.

#### Cons
- Inconsistent testing frameworks across GOV.UK applications.
- New developers may be confused about which testing framework to use.
- Goes against the guidance from the Govuk Developer Docs.

## Decision

Option 1 gives us a good balance of minimising upfront time cost while still moving towards a consistent testing framework.

## Status

Proposal

## Consequences

[whitehall]: https://github.com/alphagov/whitehall
[minitest]: https://github.com/minitest/minitest
[dev-docs]: https://github.com/alphagov/govuk-developer-docs/blob/main/source/manual/conventions-for-rails-applications.html.md#testing-utilities
[converting]: https://github.com/alphagov/content-block-manager/blob/main/docs/architecture/decisions/0003-move-out-to-new-application.md#explore-converting-test-suite-to-rspec
