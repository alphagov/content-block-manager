return unless Rails.env.development?

User.create!(
  name: "Test user",
  uid: "test-user-1",
  email: "test@gds.example.com",
  permissions: ["signin", "GDS Admin", "GDS Editor", "Managing Editor", "Sidekiq Admin"],
)

if Organisation.all.count.zero?
  print "Seeding organisations from live GOV.UK Content Store"
  organisation_response = GdsApi::ContentStore.new("https://www.gov.uk/api")
                                              .content_item("/government/organisations")

  organisation_response["details"].values.flatten.each do |organisation|
    Services.publishing_api.put_content(organisation["content_id"], {
      "base_path" => organisation["href"],
      "details" => {
        "acronym" => organisation["acronym"],
        "analytics_identifier" => organisation["analytics_identifier"],
        "brand" => organisation["brand"],
        "logo" => organisation["logo"],
      },
      "document_type" => "organisation",
      "publishing_app" => "content-block-manager",
      "rendering_app" => "frontend",
      "schema_name" => "organisation",
      "title" => organisation["title"],
      "routes" => [
        {
          "path" => organisation["href"],
          "type" => "exact",
        },
      ],
    })
    Services.publishing_api.publish(organisation["content_id"], "major")
    print "."
  end
end

if WorldLocation.countries.count.zero?
  print "Seeding countries from live GOV.UK Content Store"

  countries_response = GdsApi::ContentStore.new("https://www.gov.uk/api")
                                           .content_item("/world")

  countries_response["details"]["world_locations"].each do |country|
    Services.publishing_api.put_content(country["content_id"], {
      "details" => {
        "analytics_identifier" => country["analytics_identifier"],
      },
      "document_type" => "world_location",
      "publishing_app" => "content-block-manager",
      "schema_name" => "world_location",
      "title" => country["name"],
    })
    Services.publishing_api.publish(country["content_id"], "major")
    print "."
  end
end
