Given("a pension content block has been drafted") do
  create_pension_edition(state: :draft)
end

Given("a pension content block is awaiting fact check") do
  create_pension_edition(state: :awaiting_factcheck)
end

Given("a pension content block in the awaiting_review state exists") do
  create_pension_edition(state: :awaiting_review)
end

Given("a pension content block has been created") do
  create_published_pension_edition
end

Given("a tax content block has been created") do
  create_published_tax_edition
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

def create_pension_edition(state:, document: nil, title: "My pension")
  @content_block = create(
    :edition,
    :pension,
    state: state,
    document: document || pension_document,
    details: { description: "Some text" },
    creator: @user,
    lead_organisation_id: organisation_id,
    title:,
  )
end

def create_draft_contact_edition
  @content_block = create(
    :edition,
    :contact,
    document: contact_document,
    details: {
      "telephones" => {
        "telephone 1" => {
          "title" => "Draft Telephone",
          "telephone_numbers" => [
            { "label" => "Draft label", "telephone_number" => "020 7703 4842" },
            { "label" => "Draft label 2", "telephone_number" => "0800 123 123" },
          ],
        },
      },
    },
    creator: @user,
    lead_organisation_id: organisation_id,
    title: "My contact (draft)",
  )
end

def create_published_tax_edition
  @content_blocks ||= []
  @content_block = create(
    :edition,
    :tax,
    document: tax_document,
    details: { description: "Some text" },
    creator: @user,
    lead_organisation_id: organisation_id,
    title: "My tax",
  )
  Edition::HasAuditTrail.acting_as(@user) do
    @content_block.publish!
  end
  @content_blocks.push(@content_block)
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
      "telephones" => {
        "telephone 1" => {
          "title" => "Published Telephone",
          "telephone_numbers" => [
            { "label" => "Published label", "telephone_number" => "07860 837126" },
          ],
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

def tax_document
  @tax_document ||= create(:document, :tax)
end

def pension_document
  @pension_document ||= create(:document, :pension)
end

def contact_document
  @contact_document ||= create(:document, :contact)
end
