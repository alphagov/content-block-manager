module Edition::Cloneable
  extend ActiveSupport::Concern

  def clone_edition(creator:)
    new_edition = dup
    new_edition.assign_attributes(
      state: "draft",
      lead_organisation_id:,
      creator: creator,
      change_note: nil,
      internal_change_note: nil,
    )
    new_edition
  end

  def clone_without_blocks
    schema = document.schema
    edition_copy = dup
    schema.subschemas.each do |subschema|
      edition_copy.details.delete(subschema.id)
    end
    edition_copy
  end

  def clone_with_block(block_reference)
    subschema_name, block_name = block_reference.split(".")
    edition_copy = dup
    edition_copy.title = nil
    edition_copy.details = {}
    edition_copy.details[subschema_name] = {
      block_name => details.dig(subschema_name, block_name),
    }.compact_blank
    edition_copy
  end
end
