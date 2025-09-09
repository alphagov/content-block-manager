namespace :content_block_manager do
  desc "Import database dumps"
  task import: :environment do
    ContentBlockManager::Import.new.perform!

    puts "Imported #{User.all.count} users, " \
           "#{ContentBlockManager::ContentBlock::Document.all.count} documents, " \
           "#{ContentBlockManager::ContentBlock::Edition.all.count} editions and " \
           "#{ContentBlockManager::ContentBlock::Version.all.count} versions"
  end
end
