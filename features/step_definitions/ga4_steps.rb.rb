Then("analytics messages should have been sent for each step in the workflow") do
  edition = Edition.last
  steps = Workflow::Steps.for(edition, @schema)

  steps.each do |step|
    assert ga4_messages.any? do |message|
      message["event_name"] == @action && message["section"] == step
    end
  end
end

Then("analytics messages should have been sent for each embedded object") do
  extend SchemaHelper

  @selected_subschemas.each do |subschema|
    assert select_subschema_messages_sent_for_subschema?(subschema) if grouped_subschemas(@schema).any?
    assert add_subschema_messages_sent_for_subschema?(subschema)
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

def select_schema_messages_sent?
  assert_equal ga4_messages[0]["event_name"], @action
  assert_equal ga4_messages[0]["section"], "select_schema"
end

def select_subschema_messages_sent_for_subschema?(subschema)
  ga4_messages.any? do |message|
    message["event_name"] == @action &&
      message["section"] == "select_subschema" &&
      message["text"] == @schema.subschema(subschema).name.singularize
  end
end

def add_subschema_messages_sent_for_subschema?(subschema)
  ga4_messages.any? do |message|
    message["event_name"] == @action &&
      message["section"] == "add_#{subschema}" &&
      message["tool_name"] == @schema.block_type
  end
end
