When("I am creating a contact content block") do
  visit_new_contact_block_page
end

When("I am creating a contact address") do
  visit_new_contact_block_page
  create_contact_block
  choose "Address"
  click_button "Save and continue"
end

When("I am creating a contact link") do
  visit_new_contact_block_page
  create_contact_block
  choose "Contact link"
  click_button "Save and continue"
end

When("I am creating an email address") do
  visit_new_contact_block_page
  create_contact_block
  choose "Email address"
  click_button "Save and continue"
end

def visit_new_contact_block_page
  visit root_path
  click_link "Create content block"

  @schema = @schemas["contact"]
  Schema.expects(:find_by_block_type).with("contact").at_least_once.returns(@schema)
  choose "Contact"
  click_button "Save and continue"
end

def create_contact_block
  fill_in("Contact name", with: "Contact block title")
  fill_in("Description", with: "Description of block")
  select("Ministry of Example")
  click_button "Save and continue"
end
