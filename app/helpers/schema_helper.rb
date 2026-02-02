module SchemaHelper
  def redirect_url_for_subschema(subschema, edition)
    step = subschema.group.present? ? "#{Workflow::Step::GROUP_PREFIX}#{subschema.group}" : "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}"
    workflow_path(edition, step:)
  end
end
