Then(/^I should see the details for each (.+)'s (.+)$/) do |embedded_object_name, nested_object_name|
  edition = Edition.last
  details = edition.details[embedded_object_name.pluralize]
  details.keys.each do |k|
    details[k][nested_object_name.pluralize].each_with_index do |item, index|
      within("div[title='#{nested_object_name.titleize} #{index + 1}']") do
        item.keys.each do |key|
          assert_text item[key]
        end
      end
    end
  end
end

When(/^I check the first (.+)'s destroy checkbox$/) do |type|
  within "div[data-ga4-section='#{type.titleize}']" do
    first(".js-array-item-destroy input[type='checkbox']").set(true)
  end
end

When(/^I click to delete the first (.+)$/) do |type|
  within "div[data-ga4-section='#{type.titleize}']" do
    first(".app-c-content-block-manager-array-item-component").click_button "Remove"
  end
end

Then("I should not see {string} on the page") do |object_type|
  assert_no_text object_type
end
