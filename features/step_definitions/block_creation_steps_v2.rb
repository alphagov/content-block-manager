Given("the following time period content blocks have been drafted:") do |table|
  table.hashes.each do |row|
    organisation = Organisation.all&.find { |org| org.name == row["Organisation"] }

    document = Block::Document.new(block_type: "time_period")

    Block::TimePeriodEdition.create!(
      document: document,
      title: row["Time period name"],
      description: row["Description"],
      lead_organisation_id: organisation.id,
      creator: build(:user),
    )
  end
end

Then("I should see the details for all three available content blocks") do
  Block::TimePeriodEdition.find_each do |edition|
    expect(page).to have_content(edition.title)
    expect(page).to have_content(edition.description)
    expect(page).to have_content(edition.lead_organisation.name)
  end
end
