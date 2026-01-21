When("I visit the Content Block Manager home page") do
  visit root_path
end

When("I visit a block's content ID endpoint") do
  block = Document.last
  visit content_id_path(block.content_id)
end

When("I revisit the edit page") do
  @content_block = @content_block.document.most_recent_edition
  visit_edit_page
end

Given("I am viewing the draft edition") do
  edition = Document.last.editions.draft.most_recent
  visit document_path(edition.document)
end

Given("I am on the draft's workflow review step") do
  edition = Document.last.editions.draft.most_recent
  visit workflow_path(edition, step: "review")
end

Given("I am viewing the edition awaiting review") do
  edition = Document.last.editions.where(state: :awaiting_review).most_recent
  visit document_path(edition.document)
end

Given("I am viewing the edition awaiting fact check") do
  edition = Document.last.editions.where(state: :awaiting_factcheck).most_recent
  visit document_path(edition.document)
end
