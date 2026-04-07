require "json"

desc "Migrate contact from Content Store"
task :migrate_contact_from_content_store, [:contact_id] => :environment do |_t, args|
  contact_id = args.contact_id
  abort("Please enter a contact id") unless contact_id

  organisation_response = GdsApi::ContentStore.new("https://www.gov.uk/api")
                            .content_item(contact_id)

  contact = organisation_response["links"]["ordered_foi_contacts"].first # TBD

  document = Document.create!(
    block_type: "contact",
    sluggable_string: contact["title"].parameterize,
  )

  details = {}

  puts contact

  if contact["details"]["email_addresses"].present?
    details["email_addresses"] = {}

    contact["details"]["email_addresses"].each_with_index do |e, i|
      details["email_addresses"]["email-address-#{i + 1}"] = {
        "title" => e["title"],
        "email_address" => e["email"],
        "subject" => nil,
        "body" => nil,
      }
    end
  end

  if contact["details"]["contact_form_links"].present?
    details["contact_links"] = {}
    contact["details"]["contact_form_links"].each_with_index do |l, i|
      details["contact_links"]["contact-link-#{i + 1}"] = {
        "title" => "Contact Form URL",
        "label" => "Contact Form URL",
        "url" => l["link"],
      }
    end
  end

  if contact["details"]["post_addresses"].present?
    details["addresses"] = {}
    contact["details"]["post_addresses"].each_with_index do |a, i|
      street_address = a["street_address"]
      street_address.gsub!("\\n", "\n")
      street_address.gsub!("\\r", "\r")

      details["addresses"]["address-#{i + 1}"] = {
        "title" => a["title"],
        "recipient" => nil,
        "street_address" => "#{street_address}\n#{a['world_location']}",
        "town_or_city" => a["locality"],
        "postal_code" => a["postal_code"],
      }
    end
  end

  if contact["details"]["phone_numbers"].present?
    details["telephones"] = {}
    contact["details"]["phone_numbers"].each_with_index do |p, i|
      details["telephones"]["telephone-#{i + 1}"] = {
        "title" => "Main phone line",
        "description" => "",
        "telephone_numbers" => [
          {
            "label" => p["title"],
            "telephone_number" => p["number"],
          },
        ],
      }
    end
  end

  edition = Edition.create!(
    document:,
    details:,
    title: contact["title"],
    lead_organisation_id: organisation_response["content_id"],
    creator: User.find(1), # We don't have this yet, but we can make a migration user for this
  )

  puts "Details: #{details.inspect}"
  puts ""
  puts "Edition: #{edition.inspect}"

  # :nocov:
  if ENV["RAILS_ENV"] != "test"
    puts "Contact block `#{contact_id}` has been migrated."
  end
  # :nocov:
end
