When("I access the search API endpoint without any parameters") do
  visit "/api/blocks/search"
  @body = JSON.parse(page.source)
end

Then("the response is a list containing {int} block(s)") do |count|
  expect(@body["results"].count).to eq(count.to_i)
end

Given(/^there are the following published content blocks:$/) do |table|
  table.hashes.each_with_index do |hash, index|
    hash["lead_organisation_id"] = Organisation.all.find { |org| org.name == hash["organisation"] }.id
    hash["document"] = create(:document, hash["block_type"].to_sym)
    hash["created_at"] = index.days.ago

    if hash["details"].present?
      hash["details"] = JSON.parse(hash["details"])
    end

    create(:edition, :published, **hash.except("block_type", "organisation"))

    published_content_blocks_by_title[hash["title"]] = hash["document"]
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

When("I query the render API endpoint with the following embed codes:") do |table|
  visit_render_api(table.hashes.map { |hash| hash["embed_code"] })
end

When("I query the render API endpoint for the following content blocks:") do |table|
  visit_render_api(table.hashes.map { |hash| published_content_blocks_by_title.fetch(hash["title"]).embed_code })
end

When("I query the render API endpoint for {string} with the following features or paths:") do |title, table|
  embed_code = published_content_blocks_by_title.fetch(title).embed_code
  embed_codes = table.hashes.map do |hash|
    feature = hash["feature"]
    feature.present? ? embed_code.sub(/(\}\}+\z)/, "#{feature}\\1") : embed_code
  end

  visit_render_api(embed_codes)
end

Then("the rendered block for {string} includes:") do |lookup, table|
  rendered_block = rendered_block_for(lookup)
  expected_attributes = table.hashes.first

  expect(rendered_block).to include(expected_attributes)
  expect(rendered_block["html"]).to be_a(String)
end

Then("the rendered block for {string} includes html:") do |lookup, expected_html|
  expect(rendered_block_for(lookup)["html"]).to include(expected_html.strip)
end

Then("the response contains {int} rendered blocks") do |count|
  expect(rendered_blocks.count).to eq(count)
end

Then("the rendered block for {string} includes title {string}") do |lookup, expected_title|
  rendered_block = rendered_block_for(lookup)

  expect(rendered_block).to include("title" => expected_title)
  expect(rendered_block["html"]).to be_a(String)
  expect(rendered_block["html"]).to include(expected_title)
end

Then("the rendered block for {string} includes block type {string}") do |lookup, expected_block_type|
  expect(rendered_block_for(lookup)).to include("block_type" => expected_block_type)
end

def visit_render_api(embed_codes)
  query = URI.encode_www_form(embed_codes.map { |embed_code| ["embed_codes[]", embed_code] })
  visit "/api/blocks/render?#{query}"
  @render_body = JSON.parse(page.source)
end

def rendered_blocks
  @render_body.fetch("rendered_blocks")
end

def rendered_block_for(lookup)
  return rendered_blocks[lookup] if rendered_blocks.key?(lookup)

  title_match = rendered_blocks.values.find { |block| block["title"] == lookup }
  return title_match if title_match

  find_by_partial_key(lookup)
end

def published_content_blocks_by_title
  @published_content_blocks_by_title ||= {}
end

def find_by_partial_key(lookup)
  base_lookup = lookup.sub(/[#\/].*/, "")
  suffix = lookup.delete_prefix(base_lookup)

  if (document = published_content_blocks_by_title[base_lookup])
    expected_key = document.embed_code.sub(/(\}\}+\z)/, "#{suffix}\\1")
    return rendered_blocks[expected_key] if rendered_blocks.key?(expected_key)
  end

  _key, block = rendered_blocks.find { |key, _| key.include?(suffix.presence || base_lookup) }
  block
end
