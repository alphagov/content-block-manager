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

Given(/^the API has been configured to return one result per page$/) do
  stub_const("ContentBlock::Query::DEFAULT_PAGE_SIZE", 1)
end

When(/^I query the search API endpoint for the (first|second|third) page of results$/) do |ordinal|
  page_number = { "first" => 1, "second" => 2, "third" => 3 }[ordinal]
  visit "/api/blocks?page=#{page_number}"
  @body = JSON.parse(page.source)
end

And(/^the pagination response has the following attributes:$/) do |table|
  table.hashes.each do |hash|
    expect(@body[hash["key"]].to_s).to eq(hash["value"])
  end
end

And(/^the pagination response has the following links:$/) do |table|
  table.hashes.each do |hash|
    expect(@body["links"]).to include({
      "rel" => hash["rel"],
      "href" => hash["href"],
    })
  end
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

Then("the response is rendered HTML") do
  expect(page.status_code).to eq(200)
  expect(page.response_headers["Content-Type"]).to include("text/html")
  expect(page.source).to include("content-block")
end

Then("the response contains rendered content for {string}") do |title|
  expect(page.source).to include(title)
end

Then("the response is a not found error for embed code {string}") do |embed_code|
  response_body = JSON.parse(page.source)

  expect(page.status_code).to eq(404)
  expect(response_body).to eq({
    "error" => "Content block not found for embed code: #{embed_code}",
  })
end
