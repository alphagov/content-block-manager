module SchemaHelper
  def redirect_url_for_subschema(subschema, edition)
    step = subschema.group.present? ? "#{Workflow::Step::GROUP_PREFIX}#{subschema.group}" : "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}"
    workflow_path(edition, step:)
  end

  def valid_schemas
    show_all_content_block_types? ? Schema.all : Schema.live
  end

  def classes_for_subschema_listing_heading(subschema)
    return "subschema-listing__heading" if subschema.relationship_type.one_to_many?

    ""
  end

private

  def show_all_content_block_types?
    Flipflop.show_all_content_block_types? || Current.user&.has_permission?(User::Permissions::SHOW_ALL_CONTENT_BLOCK_TYPES)
  end
end
