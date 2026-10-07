namespace :host_content_metrics do
  desc "Refresh every block's rollup of host content metrics from Publishing API"
  task refresh_rollups: :environment do
    log = proc { |str, level = :info|
      timestamp = Time.current.strftime("%F %T")
      line = "#{timestamp} > #{str}"
      puts line unless Rails.env.test?
      Rails.logger.public_send(level, line)
    }

    documents = Document.all
    log.call("Refreshing rollup metrics for #{documents.count} #{'block'.pluralize(documents.count)}")

    refreshed = 0
    failed = 0

    documents.find_each do |document|
      HostContentItem.rollup_for(document)
      refreshed += 1
    rescue GdsApi::BaseError => e
      failed += 1
      log.call("Failed to refresh #{document.content_id}: #{e.class}: #{e.message}", :error)
    end

    log.call("Refreshed #{refreshed} #{'block'.pluralize(refreshed)}, #{failed} failed")
  end
end
