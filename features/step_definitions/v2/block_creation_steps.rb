Given("the following time period content blocks have been drafted:") do |table|
  table.hashes.each do |row|
    organisation = Organisation.all.find { |org| org.name == row["Organisation"] }
    updated_at = row["Updated at"].present? ? Date.parse(row["Updated at"]) : Time.zone.now

    document = V2::Document.create!(
      block_type: "time_period",
      updated_at: updated_at,
    )

    create(
      :v2_time_period_edition,
      document: document,
      title: row["Time period name"],
      description: row["Description"],
      lead_organisation_id: organisation.id,
      creator: build(:user),
      created_at: updated_at,
      updated_at: updated_at,
    )
  end
end

When("I fill in {string} date with {string}, {string}, {string}") do |field_label, day, month, year|
  param_key = field_label.parameterize(separator: "_")

  fill_in "#{param_key}[3i]", with: day
  fill_in "#{param_key}[2i]", with: month
  fill_in "#{param_key}[1i]", with: year
end

Given("{int} time period content blocks exist") do |count|
  V2::Document.destroy_all

  organisation = Organisation.all.first

  count.times do |i|
    document = V2::Document.create!(block_type: "time_period")
    create(
      :v2_time_period_edition,
      document: document,
      title: "Content Block #{i + 1}",
      lead_organisation_id: organisation.id,
      creator: build(:user),
    )
  end
end

Then("I should see {int} content block(s)") do |expected_count|
  expect(page).to have_css("[data-testid^='homepage-item-']", count: expected_count)
end

Given(/^a content block exists with title "([^"]*)" created (\d+) (day|days|hour|hours) ago$/) do |title, amount, unit|
  time_ago = amount.to_i.public_send(unit).ago
  organisation = Organisation.all.first

  document = V2::Document.create!(block_type: "time_period")

  create(
    :v2_time_period_edition,
    document: document,
    title: title,
    lead_organisation_id: organisation.id,
    creator: build(:user),
    created_at: time_ago,
  )
end

Then("I should see {string} listed before {string}") do |first_item, second_item|
  expect(page).to have_css("[data-testid='homepage-item-0']", text: first_item)
  expect(page).to have_css("[data-testid='homepage-item-1']", text: second_item)
end

Then("I should not see {string}") do |content|
  expect(page).to have_no_content(content)
end
