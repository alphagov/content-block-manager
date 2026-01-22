Gem::Specification.new do |spec|
  spec.name    = "block_preview"
  spec.version = "0.0.1"
  spec.authors = ["GOV.UK Dev"]
  spec.email   = ["govuk-dev@digital.cabinet-office.gov.uk"]
  spec.summary = "Rails engine for Block Preview."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.5"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*"]
  end
end
