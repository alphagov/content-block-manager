source "https://rubygems.org"

gem "babosa"
gem "bootsnap", require: false
gem "content_block_tools"
gem "dartsass-rails"
gem "flipflop"
gem "friendly_id"
gem "gds-api-adapters"
gem "gds-sso"
gem "govuk_app_config"
gem "govuk_frontend_toolkit"
gem "govuk_publishing_components"
gem "govuk_sidekiq"
gem "jbuilder"
gem "json_schemer"
gem "kaminari"
gem "pg", "~> 1.6"
gem "pg_search"
gem "plek"
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.3"
gem "record_tag_helper", require: false
gem "rinku", require: "rails_rinku"
gem "sentry-sidekiq"
gem "sprockets-rails"
gem "terser"
gem "thruster", require: false
gem "transitions", require: ["transitions", "active_record/transitions"]
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "view_component"

group :development, :test do
  gem "brakeman", require: false
  gem "byebug"
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "erb_lint"
  gem "govuk_test"
  gem "parser", require: false
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec-rails"
  gem "rubocop-govuk"
  gem "unparser", require: false
end

group :test do
  gem "climate_control"
  gem "database_cleaner-active_record"
  gem "equivalent-xml"
  gem "factory_bot"
  gem "govuk_schemas"
  gem "maxitest"
  gem "minitest"
  gem "minitest-fail-fast"
  gem "minitest-stub-const"
  gem "mocha"
  gem "mutex_m"
  gem "rails-controller-testing"
  gem "simplecov"
  gem "timecop"
  gem "webmock", require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

group :cucumber, :test do
  gem "capybara"
  gem "capybara-playwright-driver"
  gem "cucumber"
  gem "cucumber-rails", require: false
  gem "launchy"
end
