When("I am creating a pension content block") do
  visit_new_pension_block_page
end

When("I am creating a pension rate") do
  visit_new_pension_block_page
  create_pension_block
  click_link "Add a rate"
end

def visit_new_pension_block_page
  visit root_path
  click_link "Create content block"

  @schema = @schemas["pension"]
  Schema.expects(:find_by_block_type).with("pension").at_least_once.returns(@schema)
  choose "Pension"
  click_button "Save and continue"
end

def create_pension_block
  fill_in("Title", with: "Pension block title")
  fill_in("Description", with: "Description of block")
  select("Ministry of Example")
  click_button "Save and continue"
end
