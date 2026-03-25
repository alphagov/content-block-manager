Given(/^the organisation "([^"]*)" exists$/) do |name|
  @organisations ||= []
  @organisation = build(:organisation, name:)
  @organisations << @organisation
  allow(Organisation).to receive(:all).and_return(@organisations)
end
