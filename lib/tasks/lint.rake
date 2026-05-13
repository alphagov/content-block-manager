# :nocov:
desc "Run all linters"
task :lint do
  sh "bundle exec rubocop"
  sh "bundle exec erb_lint --lint-all"
  sh "yarn run lint"
  sh "yarn run lint:markdown"
end
# :nocov:
