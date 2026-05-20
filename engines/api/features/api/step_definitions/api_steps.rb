When("I access the search API endpoint without any parameters") do
  visit "/api/blocks/search"
  @body = JSON.parse(page.source)
end

Then("the response is a list containing {int} block(s)") do |count|
  expect(@body["results"].count).to eq(count.to_i)
end

Given(/^there are the following published content blocks:$/) do |table|
  table.hashes.each do |hash|
    hash["lead_organisation_id"] = Organisation.all.find { |org| org.name == hash["organisation"] }.id
    hash["document"] = create(:document, block_type: hash["block_type"])
    create(:edition, :published, **hash.except("block_type", "organisation"))
  end
end

And(/^(one|another) block has the following attributes:$/) do |_, table|
  expect(@body["results"]).to include(hash_including(table.hashes.first))
end

When("query the search API endpoint for block type {string}") do |block_type|
  visit "/api/blocks/search?block_type=#{block_type}"
  @body = JSON.parse(page.source)
end

When("I query the search API endpoint for the organisation {string}") do |organisation_name|
  organisation = Organisation.all.find { |org| org.name == organisation_name }
  visit "/api/blocks/search?lead_organisation_id=#{organisation.id}"
  @body = JSON.parse(page.source)
end

When("I query the search API endpoint for the keyword {string}") do |keyword|
  visit "/api/blocks/search?keyword=#{keyword}"
  @body = JSON.parse(page.source)
end

Given(/^the API has been configured to return one result per page$/) do
  stub_const("ContentBlock::Query::DEFAULT_PAGE_SIZE", 1)
end

When(/^I query the search API endpoint for the (first|second|third) page of results$/) do |ordinal|
  page_number = { "first" => 1, "second" => 2, "third" => 3 }[ordinal]
  visit "/api/blocks/search?page=#{page_number}"
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
