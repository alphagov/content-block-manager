Given("a pension content block has been drafted") do
  create_draft_pension_edition
end

Given("a pension content block has been created") do
  create_published_pension_edition
end

Given("a published contact edition exists") do
  create_published_contact_edition
end

Given("a draft contact edition exists") do
  create_draft_contact_edition
end

Given("a contact content block has been created") do
  @content_blocks ||= []
  @content_block = create(
    :edition,
    :contact,
    details: { description: "Some text" },
    creator: @user,
    lead_organisation_id: @organisation.id,
    title: "My contact",
  )
  Edition::HasAuditTrail.acting_as(@user) do
    @content_block.publish!
  end
  @content_blocks.push(@content_block)
end

Given(/^([^"]*) content blocks of type ([^"]*) have been created with the fields:$/) do |count, block_type, table|
  fields = table.rows_hash
  organisation_name = fields.delete("organisation")
  organisation = Organisation.all.find { |org| org.name == organisation_name }
  title = fields.delete("title") || "title"
  instructions_to_publishers = fields.delete("instructions_to_publishers")

  (1..count.to_i).each do |_i|
    document = create(:document, block_type.to_sym, sluggable_string: title.parameterize(separator: "-"))

    editions = create_list(
      :edition,
      3,
      block_type.to_sym,
      document:,
      state: "published",
      lead_organisation_id: organisation.id,
      details: fields,
      creator: @user,
      instructions_to_publishers:,
      title:,
    )

    document.latest_published_edition = editions.last
    document.save!
  end
end

def create_draft_pension_edition
  @content_block = create(
    :edition,
    :pension,
    document: pension_document,
    details: { description: "Some text" },
    creator: @user,
    lead_organisation_id: organisation_id,
    title: "My pension",
  )
end

def create_draft_contact_edition
  @content_block = create(
    :edition,
    :contact,
    document: contact_document,
    details: {
      "description" => "Further edition (Draft)",
      "contact_links" => {
        "contact-link-draft" => {
          "title" => "Contact link (Draft)",
          "label" => "Draft Link",
          "url" => "https://draft.example.com",
        },
      },
    },
    creator: @user,
    lead_organisation_id: organisation_id,
    title: "My contact (draft)",
  )
end

def create_published_pension_edition
  @content_blocks ||= []
  @content_block = create(
    :edition,
    :pension,
    document: pension_document,
    details: { description: "Some text" },
    creator: @user,
    lead_organisation_id: organisation_id,
    title: "My pension",
  )
  Edition::HasAuditTrail.acting_as(@user) do
    @content_block.publish!
  end
  @content_blocks.push(@content_block)
end

def create_published_contact_edition
  @content_blocks ||= []
  @content_block = create(
    :edition,
    :contact,
    document: contact_document,
    details: {
      "description" => "Published edition (Published)",
      "contact_links" => {
        "contact-link-published" => {
          "title" => "Contact link (Published)",
          "label" => "Published Link",
          "url" => "https://published.example.com",
        },
      },
    },
    creator: @user,
    lead_organisation_id: organisation_id,
    title: "My contact (published)",
  )
  Edition::HasAuditTrail.acting_as(@user) do
    @content_block.publish!
  end
  @content_blocks.push(@content_block)
end

def organisation_id
  Organisation.all.first.id
end

def pension_document
  @pension_document ||= create(:document, :pension)
end

def contact_document
  @contact_document ||= create(:document, :contact)
end
