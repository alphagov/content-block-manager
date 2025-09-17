# Use of Govspeak

September 3, 2025.

Govspeak is the GOV.UK flavour of markdown which is offered to content creators
to format their work.

This is a summary of how, at this point in time, we are converting Govspeak into
HTML.

## 1) GovspeakEditor: when editing content

When composing or editing a govspeak-enabled `<textarea>` we offer users the
facility to toggle between "Preview" and "Edit" modes.

When choosing to "Preview" the content of the textarea, we use Ajax to send a
`POST` request to the `/admin/preview` endpoint. The `Admin::PreviewController`
uses the `GovspeakPreviewHelper` which ultimately calls `#to_haml` on a new
`Govspeak::Document`, defined in the `govspeak` gem, a dependency of the
`content_block_tools` gem.

## 2) render_govspeak: when displaying saved content

When displaying govspeak-enabled fields which have been saved, on workflow pages
such as:

- `editions/1/workflow/group_contact_methods#telephones` or
- `editions/1/workflow/review`

The `EmbeddedObjects::SummaryCard::NestedItemComponent` uses the
`ContentBlockManager::ContentBlock::GovspeakHelper` and calls out to
`render_govspeak` in the content_block_tools gem:

```rb
module ContentBlockTools
  module Govspeak
    def render_govspeak(body, root_class: nil)
      html = ::Govspeak::Document.new(body).to_html
      Nokogiri::HTML.fragment(html).tap { |fragment|
        fragment.children[0].add_class(root_class) if root_class
      }.to_s.html_safe
    end
  end
end
```

## 3) DefaultBlockComponent: rendering entire block

Once a content block is published and can be viewed on the "show" block page:
e.g. `/content-block/1`, we use the `DefaultBlockComponent` which renders the
block using the `content_block_tools` gem:

```rb
ContentBlockTools::ContentBlock.new(
  document_type: "content_block_#{block_type}",
  content_id: document.content_id,
  title:,
  details:,
  embed_code:,
).render
```

When rendering the `ContactComponent`, for example, the `content_block_tools`
gem uses `ContentBlockTools::Govspeak::render_govspeak` (see [2]) on the
govspeak-enabled fields. See the `telephone_component.html.erb`:

```rb
<% if show_video_relay_service? %>
  <%= render_govspeak(video_relay_service_content) %>
<% end %>

<% if show_bsl_guidance? %>
  <%= render_govspeak(bsl_guidance[:value], root_class: "content-block__body") %>
<% end %>

<% if show_opening_hours? %>
  <%= render_govspeak(opening_hours[:opening_hours], root_class: "content-block__body") %>
<% end %>
```

## Notes

- Currently the only fields which can be govspeak-enabled are on embedded objects
(aka "nested objects", "nested items"). It will take a bit of work to make
`GovspeakEnabledTextareaComponent` general-purpose, as currently `govspeak-enabled?`
is defined only on `EmbeddedSchema`.

- We have two similarly named helpers which ought to be combined:

  1. `GovspeakPreviewHelper` used by GovspeakEditor
  2. `GovspeakHelper` used by `NestedItemComponent`

- We also had (copied over from Whitehall but now deleted) a
`Whitehall::GovspeakRenderer` which inherits from `ActionController::Renderer`
and provides the following `helpers` methods:

  - `govspeak_edition_to_html`
  - `govspeak_to_html`
  - `govspeak_with_attachments_to_html`
  - `govspeak_html_attachment_to_html`
  - `block_attachments`
