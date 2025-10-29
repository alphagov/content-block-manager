desc "Check coverage of last test run"
task check_coverage: :environment do
  require "simplecov"

  SimpleCov.collate Dir["coverage/**/.resultset.json"] do
    minimum_coverage ENV.fetch("MINIMUM_COVERAGE", 100).to_f
  end
end
