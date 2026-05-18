When("I access the API endpoint {string}") do |url|
  visit url
  @body = JSON.parse(page.source)
end

Then("the response is a list containing {int} block(s)") do |count|
  expect(@body.count).to eq(count.to_i)
end

Given(/^there are the following published content blocks:$/) do |table|
  table.hashes.each do |hash|
    hash["lead_organisation_id"] = Organisation.all.find { |org| org.name == hash.delete("organisation") }.id
    create(:edition, :published, **hash.merge(document: create(:document)))
  end
end

And(/^(one|another) block has the following attributes:$/) do |_, table|
  expect(@body).to include(hash_including table.hashes.first)
end
