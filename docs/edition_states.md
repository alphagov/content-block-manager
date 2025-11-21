# Edition States

## Proposed State Diagram

```mermaid
stateDiagram-v2
    [*] --> draft

    draft --> deleted: delete
    awaiting_2i --> deleted: delete
    awaiting_factcheck --> deleted: delete
    scheduled --> deleted: delete

    draft --> awaiting_2i: ready_for_2i
    awaiting_2i --> awaiting_factcheck: ready_for_factcheck
    awaiting_factcheck --> scheduled: schedule

    scheduled --> superseded: supersede
    published --> superseded: supersede

    scheduled --> published: publish
    awaiting_factcheck --> published: publish
```

## Notes

There are no backwards transitions in this model. If a user makes edits to a Published or Scheduled Edition, we
simply create a new Edition in the default (`draft`) state.

A user may propose a schedule for an edition in any state before `scheduled` or `published`. Once the Edition has
undergone all the review stages, it will be scheduled for publication. This means, for example, that a user may propose
a schedule for an Edition in the `draft` state but the state itself does not change.

## States

### draft

The default state for a new edition when created.

### awaiting_2i

Once the author has completed their work, they can request that a 2i Review (second pair of eyes) be performed.

### awaiting_factcheck

Once the 2i Review has been completed, the author can request that a fact check be performed.
This is usually done by a Subject-Matter Expert.

### scheduled

Once the Edition has gone through the whole review process, it can be scheduled for publication.

### published

Once the Edition has been published, it is no longer editable. Moving an Edition to this state pushes it live for users.

### superseded

When a user makes an edit to a Scheduled or Published Edition, the original Edition is marked as superseded.

### deleted

When a user deletes an Edition, it is marked as deleted. Rather than having a `deleted_at` column, we use a `state`.
This allows us to easily restrict which states allow deletion and follows conventions set by other publishing apps.

## Transitions

### ready_for_2i

Mark an Edition as ready for 2i Review.

### ready_for_factcheck

Mark an Edition as ready for fact check.

### schedule

Schedule an Edition for publication.

### publish

Publish an Edition to the Publishing API.

### delete

Delete an Edition.