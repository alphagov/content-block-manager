desc "Import database dumps"
task import: :environment do
  Import.new.perform!

  puts "Imported #{User.all.count} users, " \
          "#{Document.all.count} documents, " \
          "#{Edition.all.count} editions and " \
          "#{Version.all.count} versions"
end
