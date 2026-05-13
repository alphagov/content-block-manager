# :nocov:
desc "Run all linters with autocorrect"
task :lint_autocorrect do
  sh "bundle exec rubocop --autocorrect"
  sh "bundle exec erb_lint --lint-all --autocorrect"
  sh "yarn run lint:fix"
end
# :nocov:
