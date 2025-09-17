# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

require "minitest/test_task"
require "cucumber/rake/task"
# We only set this var when running via Rake, so that we can get
# sensible coverage reports when running a full test suite,
# without overwriting them when we're just running a single test
ENV["COVERAGE"] = "true"

Rails.application.load_tasks

Minitest::TestTask.create do |t|
  t.test_globs = %w[test/**/*_test.rb]
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = "--format pretty" # Any valid command line option can go here.
end

Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task default: %i[lint test cucumber]
