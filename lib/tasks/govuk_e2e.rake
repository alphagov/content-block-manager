namespace :db do
  namespace :seed do
    namespace :govuk_e2e do
      desc "Seed the Content Block Manager GOV.UK end-to-end test fixtures " \
           "(github.com/alphagov/govuk-e2e-tests content-block-manager.spec.js). " \
           "Manually invoked (independent of the default db:seed) so these " \
           "fixtures are not created for every local developer."
      task content_block_manager: :environment do
        GovukE2e::ContentBlockManager::Fixtures.seed!
      end
    end
  end
end
