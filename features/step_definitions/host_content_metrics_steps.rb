Given("a(n) {word} block {string} has rollup metrics:") do |block_type, title, table|
  values = table.rows_hash
  organisation = build(:organisation, name: values.fetch("organisation"))
  document = create_block_with_title(title, block_type:, organisation:)

  create(
    :rollup_metric,
    document:,
    lead_organisation_name: organisation.name,
    locations: values.fetch("locations"),
    instances: values.fetch("instances"),
    views: values.fetch("views"),
    organisations: values.fetch("organisations"),
    refreshed_at: Time.zone.parse(values.fetch("refreshed_at")),
  )
end

Given("a draft {word} block {string} has no rollup metrics") do |block_type, title|
  create_block_with_title(title, block_type:, state: :draft)
end

When("I visit the host content metrics page") do
  visit admin_metrics_host_content_path
end

When("I sort the metrics by {string}( again)") do |heading|
  within("#{HostContentMetricsHelpers::METRICS_TABLE} thead") do
    click_link heading
  end
end

When("I click {string} in the header") do |link_text|
  within(".govuk-header, .govuk-service-navigation", match: :first) do
    click_link link_text
  end
end

When("I view that block's page") do
  @block = @blocks.values.first
  visit document_path(@block)
end

Then("I should see the blocks in this order:") do |table|
  expect(metrics_table_titles).to eq(table.raw.flatten)
end

Then("I should see these metrics for {string}:") do |title, table|
  table.rows_hash.each do |key, expected|
    expect(metrics_table_cell(title, key).text.strip).to eq(expected)
  end
end

Then("the title {string} should link to the block's page") do |title|
  cell = metrics_table_cell(title, "title")
  expect(cell).to have_link(title, href: document_path(@blocks.fetch(title)))
end

Then("I should see {string} for each metric of {string}") do |placeholder, title|
  HostContentMetricsHelpers::METRIC_KEYS.each do |key|
    expect(metrics_table_cell(title, key).text.strip).to eq(placeholder)
  end
end

Then("I should be on the host content metrics page") do
  expect(page).to have_current_path(admin_metrics_host_content_path)
end

Then("I should see that block's rollup data in the metrics table") do
  title = @block.title
  {
    "locations" => @rollup[:locations],
    "instances" => @rollup[:instances],
    "views" => @rollup[:views],
    "organisations" => @rollup[:organisations],
  }.each do |key, value|
    expect(metrics_table_cell(title, key).text.strip).to eq(value.to_s)
  end
end

Then("I should not see {string} in the header") do |link_text|
  within(".govuk-header, .govuk-service-navigation", match: :first) do
    expect(page).not_to have_link(link_text)
  end
end

Then("I should see a permissions error") do
  expect(page.status_code).to eq(403)
  expect(page).to have_text("Permissions error")
end
