Then(/^I should see the details for each (.+)'s (.+)$/) do |embedded_object_name, nested_object_name|
  edition = Edition.last
  details = edition.details[embedded_object_name.pluralize]
  details.keys.each do |k|
    value = details[k][nested_object_name.pluralize]
    if value.is_a?(Hash)
      value.each do |nested_key, nested_value|
        assert_details_visible(nested_key, nested_value)
      end
    else
      assert_details_visible(nested_object_name, value)
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

def assert_details_visible(nested_object_name, details)
  details.each_with_index do |item, index|
    within("div[title='#{nested_object_name.titleize} #{index + 1}']") do
      item.keys.each do |key|
        if item[key].is_a?(Array)
          assert_details_visible(key.singularize, item[key])
        elsif item[key].is_a?(Hash)
          item[key].values.each do |value|
            assert_text(value) unless value.in?([true, false]) # Ignore any boolean fields, as these are usually hidden
          end
        else
          assert_text item[key]
        end
      end
    end
  end
end
