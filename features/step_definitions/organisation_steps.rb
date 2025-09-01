Given(/^the organisation "([^"]*)" exists$/) do |name|
  @organisations ||= []
  @organisation = build(:organisation, name:)
  @organisations << @organisation
  Organisation.stubs(:all).returns(@organisations)
end
