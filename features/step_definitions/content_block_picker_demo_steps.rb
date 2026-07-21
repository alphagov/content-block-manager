When("I visit the Content Block Picker Demo page") do
  visit "/content-block-picker-demo"
end

Then("I should see the heading {string}") do |heading_text|
  expect(page).to have_selector("h1", text: heading_text)
end

Then("I should see the demo textarea") do
  expect(page).to have_selector("textarea#demo-textarea.my-cbp")
end

Then("I should see the 'Insert block' button") do
  expect(page).to have_selector("button#insert-content-block-button.govuk-button")
end

Then("the content block picker CSS should be loaded") do
  expect(page).to have_selector(".content-block-highlight__wrapper", visible: :all)
end

Then("the content block picker should be initialized on the textarea") do
  expect(page).to have_selector(".content-block-highlight__wrapper textarea.my-cbp")
end

Then("there should be no JavaScript errors") do
  error_messages = Array(@js_console_messages)
                     .select { |m| m[:type] == "error" }
                     .map { |m| m[:text] }
  expect(error_messages).to be_empty, "JavaScript console errors:\n#{error_messages.join("\n")}"
end
