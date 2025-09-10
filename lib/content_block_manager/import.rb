module ContentBlockManager
  class Import
    LOOKUPS = {
      User => "/tmp/users.json",
      ContentBlockManager::ContentBlock::Document => "/tmp/content_block_documents.json",
      ContentBlockManager::ContentBlock::Edition => "/tmp/content_block_editions.json",
      ContentBlockManager::ContentBlock::Version => "/tmp/content_block_versions.json",
    }.freeze

    def perform!
      # The timestamps in the export are set to UTC, but the app is running in the "London"
      # timezone, so setting the timezone ensures the timestamps are created as UTC in the
      # database
      ActiveRecord::Base.transaction do
        Time.use_zone("UTC") do
          LOOKUPS.each do |klass, file|
            rows = JSON.parse(File.read(file))
            klass.delete_all

            rows.each do |row|
              klass.create!(**row)
            end
          end

          # As we want the IDs to be the same as the old app - this ensures the next ID is the value of the last
          # inserted ID plus 1
          ActiveRecord::Base.connection.tables.each do |t|
            ActiveRecord::Base.connection.reset_pk_sequence!(t)
          end
        end
      end
    end
  end
end
