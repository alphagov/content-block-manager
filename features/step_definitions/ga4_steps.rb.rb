Then("analytics messages should have been sent for each step in the workflow") do
  expect_select_schema_message_to_have_been_sent if @edition.document.is_new_block?

  all_steps_for_edition(Edition.last).each do |step|
    section = section_for_step(step)
    assert_messages_sent(event_name: "form_response", section:)
  end
end

Then("analytics messages should have been sent for each embedded object") do
  extend SchemaHelper

  @selected_subschemas.each do |subschema_name|
    subschema = @schema.subschema(subschema_name)
    expect_select_subschema_messages_to_have_been_sent(subschema) if SubschemaCollection.new(@schema.subschemas).grouped.any?
    expect_add_subschema_messages_to_have_been_sent(subschema)
  end
end

def ga4_messages
  @ga4_messages ||= @js_console_messages.map { |message|
    data = parse_message_text(message[:text])
    if data["event"] == "event_data"
      data["event_data"]
    end
  }.compact
end

def parse_message_text(message_text)
  JSON.parse(message_text)
rescue JSON::ParserError
  {}
end

def assert_messages_sent(**args)
  expected_messages = args.to_h.stringify_keys
  expect(ga4_messages).to include(include(expected_messages))
end

def expect_select_schema_message_to_have_been_sent
  assert_messages_sent(event_name: "form_response", section: I18n.t("document.new.title"), text: @schema.name.singularize.capitalize)
end

def expect_select_subschema_messages_to_have_been_sent(subschema)
  section = "Add #{add_indefinite_article subschema.group.humanize.singularize.downcase}"
  assert_messages_sent(event_name: "form_response", section:, text: subschema.name.singularize.capitalize)
end

def expect_add_subschema_messages_to_have_been_sent(subschema)
  section = "Add #{add_indefinite_article subschema.name.singularize.downcase}"
  assert_messages_sent(event_name: "form_response", section:, tool_name: @schema.block_type)
end

# Fetch all steps for an edition and schema, except the edit step, which is only accessed when making changes during
# the edit/create flow and the last step, which does not accept a form submission
def all_steps_for_edition(edition)
  Workflow::Steps.for(edition, @schema)
                 .map(&:name)
                 .excluding(:edit_draft, :confirmation)
end

def section_for_step(step)
  action = @edition.document.is_new_block? ? "Add" : "Edit"
  block_type = @edition.block_type
  if step.start_with?(Workflow::Step::GROUP_PREFIX)
    group_name = step.to_s.gsub(Workflow::Step::GROUP_PREFIX, "").humanize(capitalize: false)
    I18n.t("edition.workflow.steps.grouped_objects.title", group_name:, action:)
  elsif step.start_with?(Workflow::Step::SUBSCHEMA_PREFIX)
    object_name = step.to_s.gsub(Workflow::Step::SUBSCHEMA_PREFIX, "").humanize(capitalize: false)
    I18n.t("edition.workflow.steps.embedded_objects.title", object_name:, action:)
  else
    I18n.t("edition.workflow.steps.#{step.name}.title", block_type:)
  end
end
