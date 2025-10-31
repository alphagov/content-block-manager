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

## Considerations

As responsible developers we want to consider several areas here including but not limited to:
- How we divide up the workload
- How we minimise the amount of manual work needed
  - We know other teams have [scripted some/all of their changes][convert-to-rspec]
- The use of AI to help us
- Maintaining a high level of quality

### Option 1 - Incremental, as we go
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

### Option 2 - Incremental, as Jira tickets
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

### Option 3 - Up front
- We take the time out of sprint work to convert all the 100 files up-front now.

### Pros
- Consistent test style across the codebase from the start.
- No cognitive load on developers to remember to convert tests when working in old files.

### Cons
- Significant upfront time cost to convert all the files.
- Time spent on converting files ahead of feature work may delay other priorities. The team are unlikely to accept this level of
  delay in feature delivery.

### Option 4 - Do nothing
- Keep Minitest as the testing framework for this application.

#### Pros
- No time cost to convert files.

#### Cons
- Inconsistent testing frameworks across GOV.UK applications.
- New developers may be confused about which testing framework to use.
- Goes against the guidance from the Govuk Developer Docs.

### Option 5 - Vibe Coding
- We run the codebase through some AI tooling like Junie or Cursor and ask it to do the conversion for us.
- Fix any issues it can't fix.
- Assumes we have ready access to these tools.

#### Pros
- This may be a quick and easy approach, if it works.

#### Cons
- If it doesn't work, it might be quite slow to un-pick.
- Encourages us to understand less of our code base as we didn't really write it.
  - Low ownership of the resulting code.
- Doesn't improve our knowledge.

## Decision

Option 1 (converting files as we touch them) gives us a good balance of minimising upfront time cost while still moving
towards a consistent testing framework.

We have made some updates to the [rspec conversion script][convert-to-rspec] to handle our style of Minitest::Spec tests
and will use this to minimise the amount of manual work needed. It won't fix absolutely everything but it's a good base
to work from and we can add to it as we go. This should mean that a large portion of the work is automated by the script
with a small amount of manual changes needed in addition. This also allows us to convert a whole directory of tests at
once if desired.

In addition, we have done the work to capture coverage from the new RSpec tests and combine it with the existing test to
ensure that coverage doesn't drop as part of this work. This should help make sure we maintain a high quality level
whilst doing this conversion work.

In terms of AI, we've decided against using AI to convert the whole suite of test files in bulk, however developers are
free to use AI as part of their day-to-day work. This means we can use it to help with the subtleties of our incremental
conversion approach.

## Status

Accepted

## Consequences

[whitehall]: https://github.com/alphagov/whitehall
[minitest]: https://github.com/minitest/minitest
[dev-docs]: https://github.com/alphagov/govuk-developer-docs/blob/main/source/manual/conventions-for-rails-applications.html.md#testing-utilities
[converting]: https://github.com/alphagov/content-block-manager/blob/main/docs/architecture/decisions/0003-move-out-to-new-application.md#explore-converting-test-suite-to-rspec
[convert-to-rspec]: https://github.com/alphagov/collections/blob/53f903ab6499c63fb8889e4aab8ee4e7c8e384a7/lib/parsers/convert_to_rspec.rb
