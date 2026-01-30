Then("analytics messages should have been sent for each step in the workflow") do
  all_steps_for_edition(Edition.last).each do |step|
    assert_messages_sent(event_name: @action, section: step.to_s)
  end
end

Then("analytics messages should have been sent for each embedded object") do
  extend SchemaHelper

  @selected_subschemas.each do |subschema|
    expect_select_subschema_messages_to_have_been_sent(subschema) if grouped_subschemas(@schema).any?
    expect_add_subschema_messages_to_have_been_sent(subschema)
  end
end

def ga4_messages
  @ga4_messages ||= @js_console_messages.map { |message|
    data = parse_message_text(message[:text])
    if data["event"] == "event_data" && data["event_data"]["type"] == "Content Block"
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

def expect_select_subschema_messages_to_have_been_sent(subschema)
  expected_text = {
    @schema.subschema(subschema).name.singularize.capitalize => @schema.subschema(subschema).name.singularize.capitalize,
  }.to_json
  assert_messages_sent(event_name: @action, section: "select_subschema", text: expected_text)
end

def expect_add_subschema_messages_to_have_been_sent(subschema)
  assert_messages_sent(event_name: @action, section: "add_#{subschema}", tool_name: @schema.block_type)
end

# Fetch all steps for an edition and schema, except the edit step, which is only accessed when making changes during
# the edit/create flow and the last step, which does not accept a form submission
def all_steps_for_edition(edition)
  Workflow::Steps.for(edition, @schema)
                 .map(&:name)
                 .excluding(:edit_draft, :confirmation)
end
