Gem::Specification.new do |spec|
  spec.name    = "api"
  spec.version = "0.0.1"
  spec.authors = ["GOV.UK Dev"]
  spec.email   = ["govuk-dev@digital.cabinet-office.gov.uk"]
  spec.summary = "Rails engine for Content Block Manager API."
  spec.license = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*"]
  end
end
