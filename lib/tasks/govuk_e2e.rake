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

      namespace :content_block_manager do
        desc "Reset the Content Block Manager GOV.UK end-to-end test fixtures " \
             "to their seeded starting state by removing the editions of block " \
             "18 created by a test run and re-publishing the seeded edition."
        task reset: :environment do
          GovukE2e::ContentBlockManager::Fixtures.reset!
        end
      end
    end
  end
end
