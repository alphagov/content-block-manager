namespace :api do
  desc "Generate Swagger documentation from RSpec tests"
  task generate_swagger: :environment do
    ENV["PATTERN"] = "engines/api/spec/requests/**/*_spec.rb"
    ENV["SWAGGER_DRY_RUN"] = "0"
    Rake::Task["rswag:specs:swaggerize"].invoke
  end
end
