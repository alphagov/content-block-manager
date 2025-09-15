# 4. Allow order of items to be specified in blocks

Date: 2025-09-15

## Status

Accepted

## Context

We have identified a user need to allow the order of items within a composed block (such as contacts)
to be specified.

At the moment, composed blocks that consist of multiple items have their items rendered in a specified
order, and there is no way to change this on a block by block basis.

With this in mind, we need to add a mechanism to allow blocks to have an order specified
in a way that can be easily changed by a user, defaulting to a default order if no order
is given.

## Decision

We will add a new `order` field to a content block, which will optionally specify the order the items
will appear.

For example, given a `details` object for a contact like so:

```json
{
  "description": "Description goes here",
  "email_addresses": {
    "email-1": {
      ...
    }
  },
  "addresses": {
    "address-1": {
      ...
    }
  },
  "telephones": {
    "telephone-1": {
      ...
    }
  }
}
```

If we wanted the telephone number to appear first, followed by the email, then the address we would add an order field 
like so:

```json
{
  "description": "Description goes here",
  "order": ["telephones.telephone-1", "email_addresses.email-1", "addresses.address-1"],  
  "email_addresses": {
    ...
  }
}
```

Additionally, if we wanted to interleave different types of content, for example, with a data structure like this:

```json
{
  "description": "Description goes here",
  "email_addresses": {
    "email-1": {
      ...
    },
    "email-2": {
      ...
    }
  },
  "addresses": {
    "address-1": {
      ...
    },
    "address-2": {
      ...
    }
  },
  "telephones": {
    "telephone-1": {
      ...
    },
    "telephone-2": {
      ...
    }
  }
}
```

We could add an order attribute like so:

```json
  {
    ...
    "order": [
      "telephones.telephone-1", 
      "email_addresses.email-1", 
      "addresses.address-1", 
      "email_addresses.email-2",
      "addresses.address-2",
      "telephones.telephone-2"
    ],
    ...
}
```

If the `order` field is not present, then we order in a default order with Phone numbers first, followed by email 
addresses, links and postal addresses. Any items that are missing from the `order` will be presented last.

### Consequences

As we will be adding this field to the root of the `details` object, we will need some mechanism to prevent
this field from appearing on the "Create object" screen, and allow the `order` field to be updated during the
edit process in a separate Reordering screen. This could be something as simple as updating the `Schema`
model and removing the `order` object from the resulting fields.

In addition, we should only give users the ability to reorder fields on "composed" blocks, and not other block
types.

We will also need to update the [Content Block Tools gem][content-block-tools] to check if an `order` field is
present, and present the items in the specified order. If the `order` is not present, we render in the default
order.

[content-block-tools]: https://github.com/alphagov/govuk_content_block_tools
