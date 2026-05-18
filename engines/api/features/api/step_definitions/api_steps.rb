When("I access the search API endpoint without any parameters") do
  visit "/api/blocks/search"
  @body = JSON.parse(page.source)
end

Then("the response is a list containing {int} block(s)") do |count|
  expect(@body.count).to eq(count.to_i)
end

Given(/^there are the following published content blocks:$/) do |table|
  table.hashes.each do |hash|
    hash["lead_organisation_id"] = Organisation.all.find { |org| org.name == hash["organisation"] }.id
    hash["document"] = create(:document, block_type: hash["block_type"])
    create(:edition, :published, **hash.except("block_type", "organisation"))
  end
end

And(/^(one|another) block has the following attributes:$/) do |_, table|
  expect(@body).to include(hash_including table.hashes.first)
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
