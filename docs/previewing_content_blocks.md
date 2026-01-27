# Previewing a content block

There are two ways a content block's rendered content can be previewed - when using the embed code in a publishing app, and when editing an existing content block in Content Block Manager.

Preview logic exists in three different repos - Publishing API, Whitehall and Content Block Tools - with more detail below.

## Preview in a publishing app

We are currently only actively supporting this for Mainstream and Whitehall.

### Mainstream Publisher

#### User journey

1. Copy the embed code from the block's page on the Content Block Manager, this will look something like `{{embed:content_block_pension:basic-rate-pension/rates/third-rate/amount}}`

2. Paste the embed code in the Document you are editing in Mainstream Publisher (aka the Host Document)

3. Click the 'Save' button at bottom of page

4. Click the 'Preview' button at bottom of page

5. The rendered contents of the block should be visible on the draft content store

#### Technical explanation

When saving the changes to the Host Document, we trigger an update of the draft Content Store as outlined in [Saving a draft](how_embedding_works.md#saving-a-draft)

### Whitehall

#### User journey

1. Copy the embed code from the block's page on the Content Block Manager, this will look something like `{{embed:content_block_pension:basic-rate-pension/rates/third-rate/amount}}`

1. Paste the embed code into the body of the Document you are editing

1. Click the 'Preview' button at top of text area input

1. The rendered contents of the block should be visible

#### Technical explanation

This is a different process than the one above for Whitehall, because it's using a custom preview service:

1. Inline preview in Whitehall calls the `AdminGovspeakHelper` to convert the textarea govspeak to HTML

1. This then calls the Whitehall's `FindAndReplaceEmbedCodesService` which [replaces the embed codes in the HTML with the latest content of the block] (<https://github.com/alphagov/whitehall/blob/main/app/services/content_block/find_and_replace_embed_codes_service.rb>) (using Content Block Tools as above).

### Preview in Content Block Manager

#### User journey

1. Given there is a Content Block that is being embedded by some Host Documents.

1. Using the edit form for that Content Block, you will come across a "Preview" page containing links to the Host Documents.

1. These links will open up a new tab rendering the frontend content, with the new embed code content highlighted in yellow.

#### Technical explanation

There are a few differences in the code to the preview processes in publishing apps:

1. For this Content Block flow, the block has not yet been published, so we don't want to update the Host Documents yet

1. When the Host Document Preview page loads (step 3 of user journey), we go get a `PreviewContent` class, [which calls the Publishing API](https://github.com/alphagov/content-block-manager/blob/main/engines/block_preview/app/model/block_preview/preview_content.rb) to get the latest content for a Host Document

1. We then make a GET request to the Host Documents live frontend page on [Gov.UK, to transform its HTML](https://github.com/alphagov/content-block-manager/blob/main/engines/block_preview/app/model/block_preview/preview_html.rb#L17)

1. And use the data attribute on the content block `<span>` to replace [the block content with the current draft content](https://github.com/alphagov/content-block-manager/blob/main/engines/block_preview/app/model/block_preview/preview_content.rb#L120)

1. The transformed page is then served in [an iFrame on the Content Block Manager](https://github.com/alphagov/content-block-manager/blob/main/engines/block_preview/app/views/block_preview/preview/_iframe.html.erb)
