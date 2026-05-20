namespace :api do
  desc "Generate Swagger documentation from RSpec tests"
  task generate_swagger: :environment do
    ENV["PATTERN"] = "{spec,engines/*/spec}/**/*_spec.rb"
    Rake::Task["rswag:specs:swaggerize"].invoke
  end
end
