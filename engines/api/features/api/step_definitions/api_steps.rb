require "cgi"

When("I access the search API endpoint without any parameters") do
  visit "/api/blocks"
  @body = JSON.parse(page.source)
end

Then("the response is a list containing {int} block(s)") do |count|
  expect(@body["results"].count).to eq(count.to_i)
end

Given(/^there are the following published content blocks:$/) do |table|
  table.hashes.each_with_index do |hash, index|
    hash["lead_organisation_id"] = Organisation.all.find { |org| org.name == hash["organisation"] }.id
    hash["document"] = create(:document, block_type: hash["block_type"])
    hash["created_at"] = index.days.ago
    create(:edition, :published, **hash.except("block_type", "organisation"))
  end
end

And(/^(one|another) block has the following attributes:$/) do |_, table|
  expect(@body["results"]).to include(hash_including(table.hashes.first))
end

When("query the search API endpoint for block type {string}") do |block_type|
  visit "/api/blocks?block_type=#{block_type}"
  @body = JSON.parse(page.source)
end

When("I query the search API endpoint for the organisation {string}") do |organisation_name|
  organisation = Organisation.all.find { |org| org.name == organisation_name }
  visit "/api/blocks?lead_organisation_id=#{organisation.id}"
  @body = JSON.parse(page.source)
end

When("I query the search API endpoint for the keyword {string}") do |keyword|
  visit "/api/blocks?keyword=#{keyword}"
  @body = JSON.parse(page.source)
end

When("I query the render API endpoint for the block titled {string}") do |title|
  published_edition = Edition.published.find_by!(title: title)
  encoded_embed_code = CGI.escape(published_edition.document.embed_code)

  visit "/api/blocks/#{encoded_embed_code}/render"
end

When("I query the render API endpoint with the embed code {string}") do |embed_code|
  encoded_embed_code = CGI.escape(embed_code)

  visit "/api/blocks/#{encoded_embed_code}/render"
end

When("I query the render API endpoint with the embed code for the block titled {string}") do |title|
  published_edition = Edition.published.find_by!(title: title)
  encoded_embed_code = CGI.escape(published_edition.document.embed_code)

  visit "/api/blocks/#{encoded_embed_code}/render"
end

When("I query the render API endpoint with the embed code for the block titled {string} and internal content path {string}") do |title, field_path|
  published_edition = Edition.published.find_by!(title: title)
  embed_code = published_edition.document.embed_code_for_field(field_path)
  encoded_embed_code = CGI.escape(embed_code)

  visit "/api/blocks/#{encoded_embed_code}/render"
end

When("I query the render API endpoint with the embed code for the block titled {string} and format {string}") do |title, format|
  published_edition = Edition.published.find_by!(title: title)
  embed_code = published_edition.document.embed_code_for_format(format)
  encoded_embed_code = CGI.escape(embed_code)

  visit "/api/blocks/#{encoded_embed_code}/render"
end

Then("the response is rendered HTML") do
  expect(page.status_code).to eq(200)
  expect(page.response_headers["Content-Type"]).to include("text/html")
  expect(page.source).to include("content-block")
end

Then("the response contains {string}") do |title|
  expect(page.source).to include(title)
end

Then("the response does not contain {string}") do |arg|
  expect(page.source).not_to include(arg)
end

Then("the response is a not found error for embed code {string}") do |embed_code|
  response_body = JSON.parse(page.source)

  expect(page.status_code).to eq(404)
  expect(response_body).to eq({
    "error" => "Content block not found for embed code: #{embed_code}",
  })
end
