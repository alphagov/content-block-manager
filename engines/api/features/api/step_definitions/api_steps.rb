When("I access the API endpoint {string}") do |url|
  visit url
end

Then("the response should have status code {int}") do |status_code|
  expect(page.status_code).to eq(status_code)
end
