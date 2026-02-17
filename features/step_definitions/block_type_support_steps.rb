Given(/^the show_all_content_block_types feature flag is( not)? turned on$/) do |negated|
  Flipflop.stubs(:show_all_content_block_types?).returns(negated.nil?)
end

Then(/^I should( not)? see the (.+) blocks listed$/) do |negated, block_type|
  blocks = @content_blocks.filter { |block| block.block_type == block_type }

  blocks.each do |block|
    if negated
      expect(page).to_not have_text(block.title)
    else
      expect(page).to have_text(block.title)
    end
  end
end

And(/^I should( not)? be able to filter for (.+) blocks$/) do |negated, block_type|
  schema = @schemas[block_type]
  within("div.govuk-accordion__section", text: /Content block type/) do |filter|
    if negated
      expect(filter).to_not have_text(schema.name)
    else
      expect(filter).to have_text(schema.name)
    end
  end
end

Then(/^I should( not)? be able to create a (.+) block$/) do |negated, block_type|
  schema = @schemas[block_type]
  if negated
    expect(page).to_not have_selector("label", text: schema.name)
  else
    expect(page).to have_selector("label", text: schema.name)
  end
end
