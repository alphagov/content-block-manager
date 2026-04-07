require "json"

desc "Migrate contact"
task :migrate_contact, [:contact_id] => :environment do |_t, args|
  contact_id = args.contact_id.to_i
  abort("Please enter a contact id") unless contact_id

  contact = JSON.load_file("contact_#{contact_id}.json")

  document = Document.create!(
    block_type: "contact",
    sluggable_string: contact["title"].parameterize,
  )

  details = {}

  if contact["email"].present?
    details["email_addresses"] = {
      "email_address" => {
        "title" => "Email",
        "email_address" => contact["email"],
        "subject" => nil,
        "body" => nil,
      },
    }
  end

  if contact["contact_form_url"].present?
    details["contact_links"] = {
      "contact_link" => {
        "title" => "Contact Form URL",
        "label" => "Contact Form URL",
        "url" => contact["contact_form_url"],
      },
    }
  end

  if contact["street_address"].present?
    street_address = contact["street_address"]
    street_address.gsub!("\\n", "\n")
    street_address.gsub!("\\r", "\r")

    details["addresses"] = {
      "address" => {
        "title" => "#{contact['contactable_type'].humanize} Address",
        "recipient" => contact["recipient"],
        "street_address" => street_address,
        "town_or_city" => contact["locality"],
        "postal_code" => contact["postal_code"],
      },
    }
  end

  # Migrating all contact numbers as one 'telephone' with multiple 'telephone_numbers', rather than multiple
  # 'telephones' with one 'telephone_number' each but it could just as easily be the latter.
  if contact["contact_numbers"].present?
    details["telephones"] =
      { "telephone" =>
        {
          "title" => "",
          "description" => "",
          "telephone_numbers" => contact["contact_numbers"].map do |contact_number|
            {
              "label" => contact_number["label"],
              "telephone_number" => contact_number["number"],
            }
          end,
        } }
  end

  if contact["comments"].present?
    details["description"] = contact["comments"]
  end

  edition = Edition.create!(
    document:,
    details:,
    title: contact["title"],
    lead_organisation_id: contact["organisation_id"],
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
