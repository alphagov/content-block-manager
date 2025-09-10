module SchemaHelper
  def grouped_subschemas(schema)
    schema.subschemas
           .select { |subschema| subschema.group.present? }
           .group_by(&:group)
  end

  def ungrouped_subschemas(schema)
    schema.subschemas.select { |subschema| subschema.group.blank? }
  end

  def redirect_url_for_subschema(subschema, edition)
    step = subschema.group.present? ? "#{Workflow::Step::GROUP_PREFIX}#{subschema.group}" : "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}"
    workflow_path(edition, step:)
  end
end
