Given(/^the organisation "([^"]*)" exists$/) do |name|
  create_org_and_stub_content_store(:organisation, name:)
end
