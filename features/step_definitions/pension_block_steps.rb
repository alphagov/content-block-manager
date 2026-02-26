Given("the pension has a rate set") do
  pension = Edition.last
  raise "Expected a pension in the draft state" unless pension.block_type == "pension" &&
    pension.draft?

  pension.details[:rates] = {
    "my-rate" => {
      "title" => "My Rate",
      "amount" => "£123.45",
      "frequency" => "a month",
    },
  }
  pension.save!
end

When("I am creating a pension content block") do
  visit_new_pension_block_page
end

When("I am creating a pension rate") do
  visit_new_pension_block_page
  create_pension_block
  click_link "Add a rate"
end

When("I proceed without adding a rate") do
  expect(current_path).to eq(workflow_path(Edition.last, step: :embedded_rates))
  click_button "Save and continue"
end

def visit_new_pension_block_page
  visit root_path
  click_link "Create content block"

  @schema = Schema.find_by_block_type("pension")
  choose "Pension"
  click_button "Save and continue"
end

def create_pension_block
  fill_in("Title", with: "Pension block title")
  fill_in("Description", with: "Description of block")
  select("Ministry of Example")
  click_button "Save and continue"
end
